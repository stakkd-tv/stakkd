require "rails_helper"

RSpec.describe "Movies Videos", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
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

  describe "GET /movies/:movie_id/videos" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get movie_videos_path(movie_id: movie)
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
        get movie_videos_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/videos" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_videos_path(movie_id: movie), params: {video: valid_attributes}
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
          post movie_videos_path(movie_id: movie), params: {video: valid_attributes}
          video = Video.last
          expect(video.record).to eq movie
          expect(video.source).to eq "YouTube"
          expect(video.type).to eq "Trailer"
          expect(video.source_key).to eq "test_key"
          expect(video.name).to eq "Test Title"
          expect(video.thumbnail_url).to eq "Test Title URL"
        end

        it "redirects to the videos index path" do
          post movie_videos_path(movie_id: movie), params: {video: valid_attributes}
          expect(response).to redirect_to movie_videos_path(movie_id: movie)
        end
      end

      context "with invalid params" do
        it "does not create an video" do
          post movie_videos_path(movie_id: movie), params: {video: invalid_attributes}
          expect(Video.count).to eq 0
        end

        it "redirects to the videos index path with a flash alert" do
          post movie_videos_path(movie_id: movie), params: {video: invalid_attributes}
          expect(response).to redirect_to movie_videos_path(movie_id: movie)
          expect(flash[:alert]).to eq "Could not add that video. Please check that the video details are correct."
        end
      end
    end
  end

  describe "DELETE /movies/:movie_id/videos/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        video = movie.videos.create!(valid_attributes)
        delete movie_video_path(video, movie_id: movie)
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
        video = movie.videos.create!(valid_attributes)
        delete movie_video_path(video, movie_id: movie)
        expect(Video.count).to eq 0
      end

      it "renders no content" do
        video = movie.videos.create!(valid_attributes)
        delete movie_video_path(video, movie_id: movie)
        expect(response).to be_no_content
      end
    end
  end
end
