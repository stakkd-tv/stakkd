require "rails_helper"

module Users
  RSpec.describe "Ratings", type: :request do
    describe "GET /users/:user_id/ratings" do
      let(:user) { FactoryBot.create(:user, :confirmed) }
      let(:movie) { FactoryBot.create(:movie, :with_release_date, translated_title: "Rated movie") }
      let!(:rating) { FactoryBot.create(:rating, user:, item: movie, updated_at: Time.zone.local(2026, 11, 20)) }

      def rating_ids
        Nokogiri::HTML(response.body).css("article[id^=rating_]").map { |node| node["id"] }
      end

      def load_more_path
        Nokogiri::HTML(response.body).at_css("turbo-frame#load_more_ratings")["src"]
      end

      it "links the active profile tab and shows the owner's score without visitor editing" do
        get user_ratings_path(user)
        expect(response).to have_http_status(:ok)
        assert_select "a[href=?][data-active=true]", user_ratings_path(user), text: "Ratings"
        assert_select "article#rating_#{rating.id}" do
          assert_select "a", text: "Rated movie"
          assert_select "span", text: /8\/10/
          assert_select "[data-controller=rating-button]", count: 0
        end
        assert_select "h3", text: "November 2026"
      end

      it "lists all four media types independently, including Specials" do
        show = FactoryBot.create(:show, :with_premiere_date)
        specials = show.seasons.find_by!(number: 0)
        episode = FactoryBot.create(:episode, season: specials, translated_name: "Holiday special")
        [show, specials, episode].each { |item| FactoryBot.create(:rating, user:, item:) }
        get user_ratings_path(user)
        expect(rating_ids.size).to eq(4)
        assert_select "p", text: "Specials"
        assert_select "p", text: "S0E1 · Holiday special"
        assert_select "img[loading=lazy]", minimum: 4
      end

      it "combines media types and exact personal score filtering" do
        episode = FactoryBot.create(:episode)
        matching = FactoryBot.create(:rating, user:, item: episode)
        FactoryBot.create(:rating, user:, item: FactoryBot.create(:show), score: 8)
        FactoryBot.create(:rating, user:, score: 7)
        FactoryBot.create(:rating, item: movie, score: 1)
        get user_ratings_path(user, hidden_media_types: %w[Show Season], score: "8")
        expect(rating_ids).to contain_exactly("rating_#{rating.id}", "rating_#{matching.id}")
      end

      it "sorts scores with recent changes first for ties, without month headings or date controls" do
        low = FactoryBot.create(:rating, user:, score: 2)
        high = FactoryBot.create(:rating, user:, score: 10)
        tie = FactoryBot.create(:rating, user:, score: 8, updated_at: rating.updated_at + 1.day)
        get user_ratings_path(user, sort: "highest")
        expect(rating_ids).to eq([high, tie, rating, low].map { "rating_#{it.id}" })
        assert_select "#rating_items h3", count: 0
        assert_select "[data-ratings-controls-target=dates][hidden]"
        get user_ratings_path(user, sort: "lowest")
        expect(rating_ids).to eq([low, tie, rating, high].map { "rating_#{it.id}" })
      end

      it "defaults to most recently changed, with stable ordering for identical timestamps" do
        other = FactoryBot.create(:rating, user:, updated_at: rating.updated_at)
        get user_ratings_path(user)
        expect(rating_ids).to eq([other, rating].map { "rating_#{it.id}" })
        rating.update!(score: 9)
        get user_ratings_path(user)
        expect(rating_ids).to eq([rating, other].map { "rating_#{it.id}" })
      end

      it "sorts oldest changes first and preserves ascending month boundaries when loading more" do
        stub_const("Users::RatingsController::PER_PAGE", 1)
        older = FactoryBot.create(:rating, user:, updated_at: rating.updated_at - 1.month)
        get user_ratings_path(user, sort: "oldest")
        expect(rating_ids).to eq(["rating_#{older.id}"])
        assert_select "h3", text: "October 2026"
        assert_select "[data-ratings-controls-target=dates]:not([hidden])"
        get load_more_path
        expect(rating_ids).to eq(["rating_#{rating.id}"])
        assert_select "h3", text: "November 2026"
      end

      it "keeps filters outside the results loading frame" do
        get user_ratings_path(user)
        assert_select "form[data-turbo-frame=ratings_content]"
        assert_select "turbo-frame#ratings_content.dim-while-busy" do
          assert_select "article", count: 1
          assert_select "form", count: 0
        end
      end

      it "shows empty states for an empty profile, unmatched score and all types hidden" do
        get user_ratings_path(FactoryBot.create(:user))
        expect(response.body).to include("No ratings yet.")
        get user_ratings_path(user, score: 1)
        expect(response.body).to include("No ratings match these filters.")
        get user_ratings_path(user, hidden_media_types: Rating::ITEM_TYPES)
        expect(response.body).to include("No ratings match these filters.")
      end

      it "normalizes unsupported filter and sort values" do
        get user_ratings_path(user, score: "8.5", sort: "unknown", hidden_media_types: ["Unknown"])
        expect(rating_ids).to eq(["rating_#{rating.id}"])
        assert_select "option[value=recent][selected]"
        assert_select "h3", text: "November 2026"
      end

      it "preserves filters and month boundaries when loading more" do
        stub_const("Users::RatingsController::PER_PAGE", 1)
        earlier = FactoryBot.create(:rating, user:, updated_at: rating.updated_at - 1.day)
        get user_ratings_path(user, score: 8, hidden_media_types: ["Episode"], hide_dates: true)
        assert_select "turbo-frame#rating_items[data-show-dates=false]"
        assert_select "turbo-frame#load_more_ratings" do |nodes|
          src = nodes.first["src"]
          expect(src).to include("after=", "score=8", "sort=recent", "Episode", "hide_dates=true")
        end
        get load_more_path
        expect(rating_ids).to eq(["rating_#{earlier.id}"])
        assert_select "turbo-stream[action=append][target=rating_items]"
        assert_select "[data-rating-month='2026-11-01'] h3", text: "November 2026"
        assert_select "turbo-stream[action=remove][target=load_more_ratings]"
      end

      it "starts a new month heading when a later batch crosses the boundary" do
        stub_const("Users::RatingsController::PER_PAGE", 1)
        FactoryBot.create(:rating, user:, updated_at: rating.updated_at - 1.month)
        get user_ratings_path(user)
        get load_more_path
        assert_select "h3", text: "October 2026"
      end

      it "continues from the saved boundary after an earlier rating is removed" do
        stub_const("Users::RatingsController::PER_PAGE", 1)
        earlier = FactoryBot.create(:rating, user:, updated_at: rating.updated_at - 1.day)
        get user_ratings_path(user)
        next_path = load_more_path
        rating.destroy!
        get next_path
        expect(rating_ids).to eq(["rating_#{earlier.id}"])
      end

      it "uses a saved score boundary when the last visible rating changes" do
        stub_const("Users::RatingsController::PER_PAGE", 1)
        high = FactoryBot.create(:rating, user:, score: 10)
        get user_ratings_path(user, sort: "highest")
        next_path = load_more_path
        high.update!(score: 1)
        get next_path
        expect(rating_ids).to eq(["rating_#{rating.id}"])
      end

      it "falls back to the first batch for an invalid cursor" do
        get user_ratings_path(user, after: "invalid")
        expect(response).to have_http_status(:ok)
        expect(rating_ids).to eq(["rating_#{rating.id}"])
      end

      it "does not let signed-in visitors edit a public owner's scores" do
        visitor = FactoryBot.create(:user, :confirmed)
        allow(Current).to receive_messages(session: Session.new(user: visitor), user: visitor)
        get user_ratings_path(user)
        assert_select "article [data-controller=rating-button]", count: 0
      end

      it "allows owner editing through the existing rating control and me alias" do
        allow(Current).to receive_messages(session: Session.new(user:), user:)
        get user_ratings_path("me")
        assert_select "article [data-controller=rating-button][data-rating-button-score-value='8'][data-rating-button-url-value=?]", set_rating_movie_path(movie)
      end

      it "returns 404 for an unauthenticated me request" do
        get user_ratings_path("me")
        expect(response).to be_not_found
      end

      context "with a private account" do
        before { user.update!(private: true) }

        it "guards HTML, frame and filtered load-more responses before fetching ratings" do
          expect(Ratings::Query).not_to receive(:new)
          get user_ratings_path(user)
          expect(response).to redirect_to(user_path(user))
          get user_ratings_path(user, score: 8), headers: {"Turbo-Frame" => "ratings_content"}
          expect(response).to redirect_to(user_path(user))
          get user_ratings_path(user, score: 8, page: 2, format: :turbo_stream)
          expect(response).to redirect_to(user_path(user))
          expect(response.body).not_to include("Rated movie")
        end

        it "blocks a signed-in visitor and lets the owner browse their scores" do
          visitor = FactoryBot.create(:user, :confirmed)
          allow(Current).to receive_messages(session: Session.new(user: visitor), user: visitor)
          get user_ratings_path(user, format: :turbo_stream)
          expect(response).to redirect_to(user_path(user))
          allow(Current).to receive_messages(session: Session.new(user:), user:)
          get user_ratings_path(user)
          expect(response).to have_http_status(:ok)
          expect(rating_ids).to eq(["rating_#{rating.id}"])
        end
      end
    end
  end
end
