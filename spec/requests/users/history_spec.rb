require "rails_helper"

module Users
  RSpec.describe "History", type: :request do
    describe "GET /users/:id/history" do
      let(:user) { FactoryBot.create(:user, :confirmed) }

      before do
        @movie = FactoryBot.create(:movie, translated_title: "Amazing movie")
        FactoryBot.create(:history_item, item: @movie, user:, consumed_at: Date.tomorrow)
        @episode = FactoryBot.create(:episode, translated_name: "Amazing episode")
        FactoryBot.create(:history_item, item: @episode, user:, consumed_at: Date.today)
      end

      it "returns http success" do
        get user_history_index_path(user)
        expect(response).to have_http_status(:success)
      end

      it "renders the history items" do
        get user_history_index_path(user)
        assert_select "turbo-frame#history_items[data-show-dates='true']" do
          assert_select "h6.font-domine", text: "Amazing movie"
          assert_select "h6.font-domine", text: @episode.show.translated_title
          assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode"
        end
      end

      it "paginates history items" do
        stub_const("Users::HistoryController::PER_PAGE", 1)
        get user_history_index_path(user)
        assert_select "h6.font-domine", text: "Amazing movie"
        assert_select "h6.font-domine", text: @episode.show.translated_title, count: 0
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode", count: 0
      end

      it "can hide movies" do
        get user_history_index_path(user, hidden_media_types: ["movie"])
        assert_select "h6.font-domine", text: "Amazing movie", count: 0
        assert_select "h6.font-domine", text: @episode.show.translated_title
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode"
      end

      it "can hide episodes" do
        get user_history_index_path(user, hidden_media_types: ["episode"])
        assert_select "h6.font-domine", text: "Amazing movie"
        assert_select "h6.font-domine", text: @episode.show.translated_title, count: 0
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode", count: 0
      end

      it "can hide both movies and episodes" do
        get user_history_index_path(user, hidden_media_types: ["episode", "movie"])
        assert_select "h6.font-domine", text: "Amazing movie", count: 0
        assert_select "h6.font-domine", text: @episode.show.translated_title, count: 0
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode", count: 0
      end

      it "can scope by a movie" do
        movie2 = FactoryBot.create(:movie, translated_title: "Bad movie")
        FactoryBot.create(:history_item, item: movie2, user:)
        get user_history_index_path(user, scope: "movie", scope_id: @movie.id)
        assert_select "h6.font-domine", text: "Amazing movie"
        assert_select "h6.font-domine", text: "Bad movie", count: 0
        assert_select "h6.font-domine", text: @episode.show.translated_title, count: 0
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode", count: 0
      end

      it "can scope by an episode" do
        episode2 = FactoryBot.create(:episode, translated_name: "Bad episode")
        FactoryBot.create(:history_item, item: episode2, user:)
        get user_history_index_path(user, scope: "episode", scope_id: @episode.id)
        assert_select "h6.font-domine", text: "Amazing movie", count: 0
        assert_select "h6.font-domine", text: @episode.show.translated_title
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode"
        assert_select "p.text-xs", text: "S#{episode2.season.number}E#{episode2.number} - Bad episode", count: 0
      end

      it "can scope by a season" do
        get user_history_index_path(user, scope: "season", scope_id: @episode.season.id)
        assert_select "h6.font-domine", text: "Amazing movie", count: 0
        assert_select "h6.font-domine", text: @episode.show.translated_title
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode"
      end

      it "can scope by a show" do
        get user_history_index_path(user, scope: "show", scope_id: @episode.show.id)
        assert_select "h6.font-domine", text: "Amazing movie", count: 0
        assert_select "h6.font-domine", text: @episode.show.translated_title
        assert_select "p.text-xs", text: "S#{@episode.season.number}E#{@episode.number} - Amazing episode"
      end

      it "renders 404 when scope is not found" do
        get user_history_index_path(user, scope: "show", scope_id: 9999999999999999)
        expect(response).to be_not_found
      end

      it "redirects when scope is invalid" do
        get user_history_index_path(user, scope: "user", scope_id: 1)
        expect(response).to redirect_to(user_history_index_path(user))
        expect(flash[:alert]).to eq "Scope is not valid"
      end

      it "does not render dates when hide dates is true" do
        get user_history_index_path(user, hide_dates: true)
        assert_select "turbo-frame#history_items[data-show-dates='false']"
      end
    end
  end
end
