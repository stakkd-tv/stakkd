require "rails_helper"

RSpec.describe "Movies Taglines", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
  let(:country) { FactoryBot.create(:country) }
  let(:valid_attributes) {
    {
      tagline: "Test tag"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      tagline: nil
    })
  }

  describe "GET /movies/:movie_id/taglines" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get movie_taglines_path(movie_id: movie)
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
        get movie_taglines_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/taglines" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_taglines_path(movie_id: movie), params: {tagline: valid_attributes}
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
        it "creates a tagline" do
          post movie_taglines_path(movie_id: movie), params: {tagline: valid_attributes}
          tagline = Tagline.last
          expect(tagline.record).to eq movie
          expect(tagline.tagline).to eq "Test tag"
        end

        it "redirects to the taglines index path" do
          post movie_taglines_path(movie_id: movie), params: {tagline: valid_attributes}
          expect(response).to redirect_to movie_taglines_path(movie_id: movie)
        end
      end

      context "with invalid params" do
        it "does not create a tagline" do
          post movie_taglines_path(movie_id: movie), params: {tagline: invalid_attributes}
          expect(Tagline.count).to eq 0
        end

        it "redirects to the taglines index path with a flash alert" do
          post movie_taglines_path(movie_id: movie), params: {tagline: invalid_attributes}
          expect(response).to redirect_to movie_taglines_path(movie_id: movie)
          expect(flash[:alert]).to eq "Could not add that tagline."
        end
      end
    end
  end

  describe "PATCH /movies/:movie_id/taglines/:id" do
    let(:new_attributes) {
      {
        tagline: "New tag"
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        tagline = movie.taglines.create!(valid_attributes)
        patch movie_tagline_path(tagline, movie_id: movie), params: {tagline: new_attributes}
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
        it "updates the tagline" do
          tagline = movie.taglines.create!(valid_attributes)
          patch movie_tagline_path(tagline, movie_id: movie), params: {tagline: new_attributes}
          tagline.reload
          expect(tagline.tagline).to eq "New tag"
        end

        it "renders json" do
          tagline = movie.taglines.create!(valid_attributes)
          patch movie_tagline_path(tagline, movie_id: movie), params: {tagline: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the tagline" do
          tagline = movie.taglines.create!(valid_attributes)
          patch movie_tagline_path(tagline, movie_id: movie), params: {tagline: invalid_attributes}
          tagline.reload
          expect(tagline.tagline).to eq "Test tag"
        end

        it "renders json with errors" do
          tagline = movie.taglines.create!(valid_attributes)
          patch movie_tagline_path(tagline, movie_id: movie), params: {tagline: invalid_attributes}
          expect(response.status).to eq 422
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => false,
            "errors" => [
              {"tagline" => ["Tagline can't be blank"]}
            ]
          })
        end
      end
    end
  end

  describe "DELETE /movies/:movie_id/taglines/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        tagline = movie.taglines.create!(valid_attributes)
        delete movie_tagline_path(tagline, movie_id: movie)
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

      it "removes the keyword" do
        movie.taglines.create!(valid_attributes)
        tagline = movie.taglines.first
        delete movie_tagline_path(tagline, movie_id: movie)
        expect(movie.reload.taglines).to eq []
      end

      it "renders no content" do
        movie.taglines.create!(valid_attributes)
        tagline = movie.taglines.first
        delete movie_tagline_path(tagline, movie_id: movie)
        expect(response).to be_no_content
      end
    end
  end

  describe "POST /movies/:movie_id/taglines/:id/move" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        tagline = movie.taglines.create!(valid_attributes)
        post move_movie_tagline_path(tagline, movie_id: movie)
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

      it "updates the tagline position" do
        tagline = movie.taglines.create!(valid_attributes)
        post move_movie_tagline_path(tagline, movie_id: movie), params: {position: 2}
        expect(response).to be_successful
        expect(tagline.reload.position).to eq 2
      end
    end
  end
end
