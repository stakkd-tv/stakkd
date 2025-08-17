require "rails_helper"

RSpec.describe "Releases", type: :request do
  let(:country) { FactoryBot.create(:country) }
  let(:movie) { FactoryBot.create(:movie, country:) }
  let(:certification) { FactoryBot.create(:certification, country:) }
  let(:valid_attributes) {
    {
      date: "2025-01-01",
      type: Release::THEATRICAL,
      certification_id: certification.id,
      note: "Im a note"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      date: nil,
      type: nil,
      certification_id: nil
    })
  }

  describe "GET /movies/:movie_id/releases/editor" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get editor_movie_releases_path(movie_id: movie)
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
        get editor_movie_releases_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/releases" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_releases_path(movie_id: movie), params: {release: valid_attributes}
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
        it "creates a release" do
          post movie_releases_path(movie_id: movie), params: {release: valid_attributes}
          release = Release.last
          expect(release.movie).to eq movie
          expect(release.date).to eq Date.new(2025, 1, 1)
          expect(release.type).to eq Release::THEATRICAL
          expect(release.certification).to eq certification
          expect(release.note).to eq "Im a note"
        end

        it "redirects to the releases index path" do
          post movie_releases_path(movie_id: movie), params: {release: valid_attributes}
          expect(response).to redirect_to editor_movie_releases_path(movie_id: movie)
        end
      end

      context "with invalid params" do
        it "does not create a release" do
          post movie_releases_path(movie_id: movie), params: {release: invalid_attributes}
          expect(Release.count).to eq 0
        end

        it "redirects to the releases index path with a flash alert" do
          post movie_releases_path(movie_id: movie), params: {release: invalid_attributes}
          expect(response).to redirect_to editor_movie_releases_path(movie_id: movie)
          expect(flash[:alert]).to eq "Release could not be added."
        end
      end
    end
  end

  describe "PATCH /movies/:movie_id/releases/:id" do
    let(:new_certification) { FactoryBot.create(:certification) }
    let(:new_attributes) {
      {
        date: "2025-02-02",
        type: Release::PREMIERE,
        certification_id: new_certification.id,
        note: "New note"
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        release = movie.releases.create!(new_attributes)
        patch movie_release_path(release, movie_id: movie), params: {release: new_attributes}
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
        it "updates the release" do
          release = movie.releases.create!(valid_attributes)
          patch movie_release_path(release, movie_id: movie), params: {release: new_attributes}
          release.reload
          expect(release.date).to eq Date.new(2025, 2, 2)
          expect(release.type).to eq Release::PREMIERE
          expect(release.certification).to eq new_certification
          expect(release.note).to eq "New note"
        end

        it "renders json" do
          release = movie.releases.create!(valid_attributes)
          patch movie_release_path(release, movie_id: movie), params: {release: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the release" do
          release = movie.releases.create!(valid_attributes)
          patch movie_release_path(release, movie_id: movie), params: {release: invalid_attributes}
          release.reload
          expect(release.date).to eq Date.new(2025, 1, 1)
        end

        it "renders json with errors" do
          release = movie.releases.create!(valid_attributes)
          patch movie_release_path(release, movie_id: movie), params: {release: invalid_attributes}
          expect(response.status).to eq 422
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => false,
            "errors" => [
              {"certification" => ["Certification must exist"]},
              {"type" => ["Type can't be blank", "Type is not included in the list"]},
              {"date" => ["Date can't be blank"]}
            ]
          })
        end
      end
    end
  end

  describe "DELETE /movies/:movie_id/releases/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        release = movie.releases.create!(valid_attributes)
        delete movie_release_path(release, movie_id: movie)
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

      it "removes the release" do
        release = movie.releases.create!(valid_attributes)
        delete movie_release_path(release, movie_id: movie)
        expect(movie.reload.releases).to eq []
      end

      it "renders no content" do
        release = movie.releases.create!(valid_attributes)
        delete movie_release_path(release, movie_id: movie)
        expect(response).to be_no_content
      end
    end
  end
end
