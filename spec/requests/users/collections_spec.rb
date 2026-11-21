require "rails_helper"

RSpec.describe "Users::Collections", type: :request do
  let(:user) { FactoryBot.create(:user, :confirmed) }
  let(:show) { FactoryBot.create(:show, :with_premiere_date) }
  let(:season) { show.seasons_without_specials.first }
  let(:episode) { season.episodes.first }

  before do
    FactoryBot.create(:collection_item, user:, item: episode)
  end

  describe "GET /users/:user_id/collection" do
    it "renders a public collection and links the profile tab" do
      get user_collection_path(user)
      expect(response).to have_http_status(:ok)
      assert_select "a[href=?][data-active=true]", user_collection_path(user), text: "Collection"
      assert_select "turbo-frame#collection_content" do
        assert_select "h6", text: show.translated_title
      end
    end

    it "shows a useful empty state for an empty collection and empty filter results" do
      get user_collection_path(FactoryBot.create(:user))
      expect(response.body).to include("No items in this collection yet.")
      get user_collection_path(user, hidden_media_types: ["Show"])
      expect(response.body).to include("No collection items match these filters.")
    end

    it "paginates complete groups and retains filters in the lazy stream URL" do
      stub_const("Users::CollectionsController::PER_PAGE", 1)
      movie = FactoryBot.create(:movie, translated_title: "Apple")
      FactoryBot.create(:collection_item, user:, item: movie)
      get user_collection_path(user, sort: "title", formats: ["none"])
      assert_select "turbo-frame#collection_groups h6", text: "Apple"
      assert_select "turbo-frame#load_more_collection_groups" do |frames|
        expect(frames.first["src"]).to include("page=2", "sort=title", "none")
      end
      get user_collection_path(user, page: 2, sort: "title", formats: ["none"], format: :turbo_stream)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      assert_select "turbo-stream[action=append][target=collection_groups]"
      assert_select "turbo-stream[action=remove][target=load_more_collection_groups]"
      expect(response.body).to include(show.translated_title)
    end

    it "does not expose another user's custom format names" do
      FactoryBot.create(:collection_format, name: "Private custom format")
      get user_collection_path(user)
      expect(response.body).not_to include("Private custom format")
    end

    it "does not allow a signed-in visitor to browse a private collection" do
      user.update!(private: true)
      visitor = FactoryBot.create(:user, :confirmed)
      allow(Current).to receive_messages(session: Session.new(user: visitor), user: visitor)
      get user_collection_path(user)
      expect(response).to redirect_to(user_path(user))
    end

    context "when me is requested without a session" do
      it "returns 404" do
        get user_collection_path("me")
        expect(response).to be_not_found
      end
    end

    context "when the collection is private" do
      before { user.update!(private: true) }

      it "redirects a visitor to the profile" do
        get user_collection_path(user)
        expect(response).to redirect_to(user_path(user))
        expect(response.body).not_to include(episode.translated_name)
      end

      it "guards the Turbo stream response" do
        get user_collection_path(user, format: :turbo_stream, page: 2)
        expect(response).to redirect_to(user_path(user))
      end

      it "lets the owner access their collection through me" do
        allow(Current).to receive_messages(session: Session.new(user:), user:)
        get user_collection_path("me")
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /users/:user_id/collection/shows/:show_id" do
    it "opens a show inside the collection frame with a separate Specials section" do
      special = FactoryBot.create(:episode, season: show.seasons.find_by!(number: 0))
      FactoryBot.create(:collection_item, user:, item: special)
      get user_collection_show_path(user, show), headers: {"Turbo-Frame" => "collection_content"}
      expect(response).to have_http_status(:ok)
      assert_select "turbo-frame#collection_content" do
        assert_select "summary", text: /Season 1/
        assert_select "summary", text: /Specials/
        assert_select "turbo-frame[src]", count: 2
      end
    end

    it "shows active format filters and matching counts" do
      bluray = FactoryBot.create(:collection_format, :common)
      second = FactoryBot.create(:episode, season:, number: 2, translated_name: "Matching episode")
      entry = FactoryBot.create(:collection_item, user:, item: second)
      FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: bluray)
      get user_collection_show_path(user, show, formats: [bluray.id])
      expect(response.body).to include("1 matching episode")
      assert_select "span", text: "Active format filters"
      assert_select "span", text: "Blu-ray"

      get user_collection_show_path(user, show, formats: [bluray.id, "none"])
      assert_select "span", text: "No format specified"
      expect(response.body).to include("2 matching episodes")
    end

    context "when no episodes match" do
      it "returns 404 to a visitor" do
        get user_collection_show_path(user, show, hidden_media_types: ["Show"])
        expect(response).to be_not_found
      end

      it "returns the owner to the collection with filters preserved" do
        allow(Current).to receive_messages(session: Session.new(user:), user:)
        get user_collection_show_path(user, show, hidden_media_types: ["Show"], sort: "title")
        expect(response).to redirect_to(user_collection_path(user, hidden_media_types: ["Show"], sort: "title"))
      end
    end

    context "when the show does not exist" do
      it "returns 404" do
        get user_collection_show_path(user, "missing-0")
        expect(response).to be_not_found
      end
    end

    context "when the collection is private" do
      before { user.update!(private: true) }

      it "redirects a visitor to the profile" do
        get user_collection_show_path(user, show)
        expect(response).to redirect_to(user_path(user))
        expect(response.body).not_to include(episode.translated_name)
      end

      it "lets the owner access their collection through me" do
        allow(Current).to receive_messages(session: Session.new(user:), user:)
        get user_collection_show_path("me", show)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /users/:user_id/collection/shows/:show_id/seasons/:season_number" do
    it "paginates episode rows inside their season frame" do
      stub_const("Users::CollectionsController::EPISODES_PER_PAGE", 1)
      second = FactoryBot.create(:episode, season:, number: 2, translated_name: "Second episode")
      FactoryBot.create(:collection_item, user:, item: second)
      get user_collection_season_path(user, show, season.number)
      assert_select "turbo-frame#collection_season_#{season.id}" do
        assert_select "a", text: "E1 · #{episode.translated_name}"
        assert_select "a", text: "More episodes"
        assert_select "a", text: "E2 · Second episode", count: 0
      end
      get user_collection_season_path(user, show, season.number, page: 2)
      assert_select "a", text: "E2 · Second episode"
      assert_select "a", text: "Previous episodes"
    end

    it "only renders episodes matching the selected formats" do
      bluray = FactoryBot.create(:collection_format, :common)
      second = FactoryBot.create(:episode, season:, number: 2, translated_name: "Matching episode")
      entry = FactoryBot.create(:collection_item, user:, item: second)
      FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: bluray)
      get user_collection_season_path(user, show, season.number, formats: [bluray.id])
      assert_select "a", text: "E2 · Matching episode"
      assert_select "a", text: "E1 · #{episode.translated_name}", count: 0
    end

    context "when the season does not exist" do
      it "returns 404" do
        get user_collection_season_path(user, show, 99)
        expect(response).to be_not_found
      end
    end

    context "when the collection is private" do
      before { user.update!(private: true) }

      it "redirects a visitor to the profile" do
        get user_collection_season_path(user, show, season.number)
        expect(response).to redirect_to(user_path(user))
        expect(response.body).not_to include(episode.translated_name)
      end

      it "lets the owner access their collection through me" do
        allow(Current).to receive_messages(session: Session.new(user:), user:)
        get user_collection_season_path("me", show, season.number)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
