require "rails_helper"

RSpec.describe "Season Videos", type: :request do
  let(:season) { FactoryBot.create(:season) }
  let(:valid_attributes) {
    {
      source: "YouTube",
      source_key: "test_key",
      type: "Trailer"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      source: nil,
      source_key: nil,
      type: nil
    })
  }

  before do
    allow_any_instance_of(Videos::YouTube).to receive(:title).and_return("Test Title")
    allow_any_instance_of(Videos::YouTube).to receive(:thumbnail_url).and_return("Test Title URL")
  end

  describe "GET /shows/:show_id/seasons/:season_id/videos" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get show_season_videos_path(season_id: season, show_id: season.show)
        expect(response).to redirect_to new_session_path
      end
    end

    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get show_season_videos_path(season_id: season, show_id: season.show)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /shows/:show_id/seasons/:season_id/videos" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post show_season_videos_path(season_id: season, show_id: season.show), params: {video: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end

    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid params" do
        it "creates a video" do
          post show_season_videos_path(season_id: season, show_id: season.show), params: {video: valid_attributes}
          video = Video.last
          expect(video.record).to eq season
          expect(video.source).to eq "YouTube"
          expect(video.type).to eq "Trailer"
          expect(video.source_key).to eq "test_key"
          expect(video.name).to eq "Test Title"
          expect(video.thumbnail_url).to eq "Test Title URL"
        end

        it "redirects to the videos index path" do
          post show_season_videos_path(season_id: season, show_id: season.show), params: {video: valid_attributes}
          expect(response).to redirect_to show_season_videos_path(season_id: season, show_id: season.show)
        end
      end

      context "with invalid params" do
        it "does not create an video" do
          post show_season_videos_path(season_id: season, show_id: season.show), params: {video: invalid_attributes}
          expect(Video.count).to eq 0
        end

        it "redirects to the videos index path with a flash alert" do
          post show_season_videos_path(season_id: season, show_id: season.show), params: {video: invalid_attributes}
          expect(response).to redirect_to show_season_videos_path(season_id: season, show_id: season.show)
          expect(flash[:alert]).to eq "Could not add that video. Please check that the video details are correct."
        end
      end
    end
  end

  describe "DELETE /shows/:show_id/seasons/:season_id/videos/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        video = season.videos.create!(valid_attributes)
        delete show_season_video_path(video, season_id: season, show_id: season.show)
        expect(response).to redirect_to new_session_path
      end
    end

    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "deletes the video" do
        video = season.videos.create!(valid_attributes)
        delete show_season_video_path(video, season_id: season, show_id: season.show)
        expect(Video.count).to eq 0
      end

      it "renders no content" do
        video = season.videos.create!(valid_attributes)
        delete show_season_video_path(video, season_id: season, show_id: season.show)
        expect(response).to be_no_content
      end
    end
  end
end
