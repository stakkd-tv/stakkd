require "rails_helper"

RSpec.describe "Movies GenreAssignments", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
  let(:genre) { FactoryBot.create(:genre) }
  let(:valid_attributes) {
    {
      genre_id: genre.id
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      genre_id: nil
    })
  }

  describe "GET /movies/:movie_id/genre_assignments" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get movie_genre_assignments_path(movie_id: movie)
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
        get movie_genre_assignments_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/genre_assignments" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_genre_assignments_path(movie_id: movie), params: {genre_assignment: valid_attributes}
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
        it "creates an genre assignment" do
          post movie_genre_assignments_path(movie_id: movie), params: {genre_assignment: valid_attributes}
          genre_assignment = GenreAssignment.last
          expect(genre_assignment.record).to eq movie
          expect(genre_assignment.genre).to eq genre
        end

        it "redirects to the genre assignments index path" do
          post movie_genre_assignments_path(movie_id: movie), params: {genre_assignment: valid_attributes}
          expect(response).to redirect_to movie_genre_assignments_path(movie_id: movie)
        end
      end

      context "with invalid params" do
        it "does not create a genre assignment" do
          post movie_genre_assignments_path(movie_id: movie), params: {genre_assignment: invalid_attributes}
          expect(GenreAssignment.count).to eq 0
        end

        it "redirects to the alternative names index path with a flash alert" do
          post movie_genre_assignments_path(movie_id: movie), params: {genre_assignment: invalid_attributes}
          expect(response).to redirect_to movie_genre_assignments_path(movie_id: movie)
          expect(flash[:alert]).to eq "Could not add genre. You must choose a genre from the dropdown and can't assign the same genre twice."
        end
      end
    end
  end

  describe "DELETE /movies/:movie_id/genre_assignments/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        genre_assignment = movie.genre_assignments.create!(valid_attributes)
        delete movie_genre_assignment_path(genre_assignment, movie_id: movie)
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

      it "deletes the genre assignment" do
        genre_assignment = movie.genre_assignments.create!(valid_attributes)
        delete movie_genre_assignment_path(genre_assignment, movie_id: movie)
        expect(GenreAssignment.count).to eq 0
      end

      it "renders no content" do
        genre_assignment = movie.genre_assignments.create!(valid_attributes)
        delete movie_genre_assignment_path(genre_assignment, movie_id: movie)
        expect(response).to be_no_content
      end
    end
  end
end
