require "rails_helper"
require_relative "shared_examples/actions/history"
require_relative "shared_examples/actions/stacks"

RSpec.describe "/shows/:show_id/seasons", type: :request do
  let(:show) { FactoryBot.create(:show) }
  let(:number) { 1 }
  let(:valid_attributes) {
    {
      number:,
      translated_name: "Season 1",
      original_name: "Season 1",
      overview: "This is an overview"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      number: nil,
      translated_name: nil,
      original_name: nil
    })
  }

  describe "GET /shows/:show_id/seasons/:id" do
    it "renders a successful response" do
      season = FactoryBot.create(:season, show:)
      get show_season_url(season, show_id: show)
      expect(response).to be_successful
    end

    context "when there is no season with that number" do
      it "responds with 404" do
        get show_season_url(1, show_id: show)
        expect(response).to be_not_found
      end
    end
  end

  describe "GET /shows/:show_id/seasons/new" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get new_show_season_url(show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get new_show_season_url(show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:show_id/seasons/:id/edit" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        season = FactoryBot.create(:season, show:)
        get edit_show_season_url(season, show_id: show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        season = FactoryBot.create(:season, show:)
        get edit_show_season_url(season, show_id: show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /shows/:show_id/seasons" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new Season" do
          post show_seasons_url(show), params: {season: valid_attributes}
          season = Season.includes(:show).last
          expect(season.show).to eq show
          expect(season.number).to eq 1
          expect(season.translated_name).to eq "Season 1"
          expect(season.original_name).to eq "Season 1"
          expect(season.overview).to eq "This is an overview"
        end

        it "redirects to the created seasons's edit page" do
          post show_seasons_url(show), params: {season: valid_attributes}
          expect(response).to redirect_to(edit_show_season_url(Season.last, show_id: show))
        end
      end

      context "with invalid parameters" do
        it "does not create a new season" do
          post show_seasons_url(show), params: {season: invalid_attributes}
          expect(show.seasons.count).to eq 1
          expect(show.seasons.first.number).to eq 0
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post show_seasons_url(show), params: {season: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "with season number of 0" do
        let(:number) { 0 }

        it "does not create a new season" do
          post show_seasons_url(show), params: {season: valid_attributes}
          expect(show.seasons.count).to eq 1
          expect(show.seasons.first.number).to eq 0
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post show_seasons_url(show), params: {season: valid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post show_seasons_url(show), params: {season: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /shows/:show_id/seasons/:id" do
    let(:new_attributes) {
      {
        number: 3,
        translated_name: "Season 3",
        original_name: "Season 3",
        overview: "This is season 3"
      }
    }

    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "updates the requested season" do
          season = show.seasons.create! valid_attributes
          patch show_season_url(season, show_id: show), params: {season: new_attributes}
          season.reload
          expect(season.number).to eq 3
          expect(season.translated_name).to eq "Season 3"
          expect(season.original_name).to eq "Season 3"
          expect(season.overview).to eq "This is season 3"
          expect(season.show).to eq show
        end

        it "redirects to the season" do
          season = show.seasons.create! valid_attributes
          patch show_season_url(season, show_id: show), params: {season: new_attributes}
          expect(response).to redirect_to(show_season_url(season.reload, show_id: show))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          season = show.seasons.create! valid_attributes
          patch show_season_url(season, show_id: show), params: {season: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        season = FactoryBot.create(:season, show:)
        patch show_season_url(season, show_id: show), params: {show: new_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:show_id/seasons/:id/posters" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        show = FactoryBot.create(:show)
        get posters_show_season_path(show.seasons.first, show_id: show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        show = FactoryBot.create(:show)
        get posters_show_season_path(show.seasons.first, show_id: show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:show_id/seasons/:id/cast" do
    it "renders the cast and crew members" do
      show = FactoryBot.create(:show)
      season = show.seasons.first
      FactoryBot.create(:episode, season: season)
      FactoryBot.create(:cast_member, record: season, person: FactoryBot.build(:person, translated_name: "John Doe"), character: "Bob")
      get cast_show_season_path(season, show_id: show)
      assert_select "h4", text: "Cast"
      assert_select "h5", text: "John Doe"
      assert_select "p", text: "Bob (1 episode)"
    end
  end

  it_behaves_like "a model with history actions" do
    let(:record) { FactoryBot.create(:season, :with_premiere_date, date_for_premiere: Date.new(2026, 1, 1)) }

    def perform_add_to_history
      post add_to_history_show_season_path(record, show_id: record.show), params: params
    end

    def perform_remove_from_history
      delete remove_from_history_show_season_path(record, show_id: record.show)
    end

    def mark_as_not_released
      record.episodes.destroy_all
    end
  end

  it_behaves_like "stackable actions" do
    let(:item) { FactoryBot.create(:season) }

    def perform_add_to_stack
      params = {stack_id:}
      post add_to_stack_show_season_path(item, show_id: item.show), params: params
    end

    def perform_create_and_add_to_stack
      params = {stack_name:}
      post create_and_add_to_stack_show_season_path(item, show_id: item.show), params: params
    end

    def perform_remove_from_stack
      params = {stack_id:}
      delete remove_from_stack_show_season_path(item, show_id: item.show), params: params
    end

    def perform_load_more_top_stacks(format: :html)
      get load_more_top_stacks_show_season_path(item, show_id: item.show, format: format)
    end
  end
end
