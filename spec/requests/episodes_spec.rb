require "rails_helper"

RSpec.describe "/shows/:show_id/seasons/:season_id/episodes", type: :request do
  let(:season) { FactoryBot.create(:season) }
  let(:valid_attributes) {
    {
      number: 1,
      translated_name: "Episode 1",
      original_name: "Episode 1",
      overview: "This is an overview",
      original_air_date: Date.new(2022, 1, 1),
      episode_type: Episode::STANDARD,
      runtime: 10,
      production_code: 304,
      imdb_id: "tt000000"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      translated_name: nil,
      original_name: nil,
      episode_type: nil
    })
  }

  describe "GET /shows/:show_id/seasons/:season_id/episodes/:id" do
    it "renders a successful response" do
      episode = FactoryBot.create(:episode, season:)
      get show_season_episode_url(episode, season_id: season, show_id: season.show)
      expect(response).to be_successful
    end

    context "when there is no episode with that number" do
      it "responds with 404" do
        get show_season_episode_url(1, season_id: season, show_id: season.show)
        expect(response).to be_not_found
      end
    end
  end

  describe "GET /shows/:show_id/seasons/:season_id/episodes/new" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get new_show_season_episode_url(season, show_id: season.show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get new_show_season_episode_url(season, show_id: season.show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:show_id/seasons/:season_id/episodes/:id/edit" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        episode = FactoryBot.create(:episode, season:)
        get edit_show_season_episode_url(episode, season_id: season, show_id: season.show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        episode = FactoryBot.create(:episode, season:)
        get edit_show_season_episode_url(episode, season_id: season, show_id: season.show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /shows/:show_id/seasons/:season_id/episodes" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new Episode" do
          post show_season_episodes_url(season.show, season), params: {episode: valid_attributes}
          episode = Episode.last
          expect(episode.season).to eq season
          expect(episode.number).to eq 1
          expect(episode.translated_name).to eq "Episode 1"
          expect(episode.original_name).to eq "Episode 1"
          expect(episode.overview).to eq "This is an overview"
          expect(episode.original_air_date).to eq Date.new(2022, 1, 1)
          expect(episode.episode_type).to eq Episode::STANDARD
          expect(episode.runtime).to eq 10
          expect(episode.production_code).to eq "304"
          expect(episode.imdb_id).to eq "tt000000"
        end

        it "redirects to the created episodes's edit page" do
          post show_season_episodes_url(season.show, season), params: {episode: valid_attributes}
          expect(response).to redirect_to(edit_show_season_episode_url(Episode.last, season_id: season, show_id: season.show))
        end
      end

      context "with invalid parameters" do
        it "does not create a new episode" do
          post show_season_episodes_url(season.show, season), params: {episode: invalid_attributes}
          expect(season.episodes.count).to eq 0
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post show_season_episodes_url(season.show, season), params: {episode: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post show_season_episodes_url(season.show, season), params: {episode: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /shows/:show_id/seasons/:id" do
    let(:new_attributes) {
      {
        number: 2,
        translated_name: "Episode 2",
        original_name: "Episode 2",
        overview: "This is an overview update",
        original_air_date: Date.new(2022, 1, 2),
        episode_type: Episode::MID_SEASON_FINALE,
        runtime: 11,
        production_code: 305,
        imdb_id: "tt000001"
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
        it "updates the requested episode" do
          episode = season.episodes.create! valid_attributes
          patch show_season_episode_url(episode, season_id: season, show_id: season.show), params: {episode: new_attributes}
          episode.reload
          expect(episode.season).to eq season
          expect(episode.number).to eq 2
          expect(episode.translated_name).to eq "Episode 2"
          expect(episode.original_name).to eq "Episode 2"
          expect(episode.overview).to eq "This is an overview update"
          expect(episode.original_air_date).to eq Date.new(2022, 1, 2)
          expect(episode.episode_type).to eq Episode::MID_SEASON_FINALE
          expect(episode.runtime).to eq 11
          expect(episode.production_code).to eq "305"
          expect(episode.imdb_id).to eq "tt000001"
        end

        it "redirects to the episode" do
          episode = season.episodes.create! valid_attributes
          patch show_season_episode_url(episode, season_id: season, show_id: season.show), params: {episode: new_attributes}
          expect(response).to redirect_to(show_season_episode_url(episode.reload, season_id: season, show_id: season.show))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          episode = season.episodes.create! valid_attributes
          patch show_season_episode_url(episode, season_id: season, show_id: season.show), params: {episode: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        episode = season.episodes.create! valid_attributes
        patch show_season_episode_url(episode, season_id: season, show_id: season.show), params: {episode: new_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:show_id/seasons/:season_id/episodes/:id/backgrounds" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        episode = FactoryBot.create(:episode)
        get backgrounds_show_season_episode_path(episode, season_id: episode.season, show_id: episode.show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        episode = FactoryBot.create(:episode)
        get backgrounds_show_season_episode_path(episode, season_id: episode.season, show_id: episode.show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:show_id/seasons/:season_id/episodes/:id/cast" do
    it "renders the cast and crew members" do
      show = FactoryBot.create(:show)
      episode = FactoryBot.create(:episode, season: show.seasons.first)
      FactoryBot.create(:cast_member, record: episode, person: FactoryBot.build(:person, translated_name: "John Doe"), character: "Bob")
      FactoryBot.create(:crew_member, record: episode, person: FactoryBot.build(:person, translated_name: "Charlie Doe"), job: FactoryBot.build(:job, department: "Art", name: "Painter"))
      get cast_show_season_episode_path(episode, season_id: episode.season, show_id: show)
      assert_select "h4", text: "Cast"
      assert_select "h5", text: "John Doe"
      assert_select "p", text: "Bob"

      assert_select "h4", text: "Art"
      assert_select "h5", text: "Charlie Doe"
      assert_select "p", text: "Painter"
    end
  end
end
