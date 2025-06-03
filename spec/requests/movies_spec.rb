require "rails_helper"

RSpec.describe "Movies", type: :request do
  let(:country) { FactoryBot.create(:country) }
  let(:language) { FactoryBot.create(:language) }
  let(:valid_attributes) {
    {
      language_id: language.id,
      country_id: country.id,
      original_title: "Back to the Future",
      translated_title: "Back to the Future",
      overview: "This is an overview",
      status: "released",
      runtime: 100,
      revenue: 100000000,
      budget: 100000000,
      homepage: "https://google.com",
      imdb_id: "tt0000000"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      language_id: nil,
      country_id: nil,
      translated_title: nil,
      original_title: nil,
      runtime: nil,
      revenue: nil,
      budget: nil,
      status: "invalid"
    })
  }

  describe "GET /movies" do
    it "renders a successful response" do
      get movies_url
      expect(response).to be_successful
    end
  end

  describe "GET /movies/:id" do
    it "renders a successful response" do
      movie = FactoryBot.create(:movie)
      get movie_url(movie)
      expect(response).to be_successful
    end
  end

  describe "GET /movies/new" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get new_movie_url
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get new_movie_url
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /movies/:id/edit" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        movie = FactoryBot.create(:movie)
        get edit_movie_url(movie)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        movie = FactoryBot.create(:movie)
        get edit_movie_url(movie)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /movies" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new Person" do
          post movies_url, params: {movie: valid_attributes}
          movie = Movie.last
          expect(movie.language).to eq language
          expect(movie.country).to eq country
          expect(movie.original_title).to eq "Back to the Future"
          expect(movie.translated_title).to eq "Back to the Future"
          expect(movie.overview).to eq "This is an overview"
          expect(movie.status).to eq "released"
          expect(movie.runtime).to eq 100
          expect(movie.revenue).to eq 100000000
          expect(movie.budget).to eq 100000000
          expect(movie.homepage).to eq "https://google.com"
          expect(movie.imdb_id).to eq "tt0000000"
        end

        it "redirects to the created movie's edit page" do
          post movies_url, params: {movie: valid_attributes}
          expect(response).to redirect_to(edit_movie_url(Movie.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new movie" do
          expect {
            post movies_path, params: {movie: invalid_attributes}
          }.to change(Movie, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post movies_path, params: {movie: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post movies_path, params: {person: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /movies/:id" do
    let(:new_attributes) {
      {
        original_title: "Berk to the Future",
        translated_title: "Berk to the Future",
        overview: "This is a new overview",
        status: "cancelled",
        runtime: 110,
        revenue: 150000000,
        budget: 140000000,
        homepage: "https://github.com",
        imdb_id: "tt0000001"
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
        it "updates the requested movie" do
          movie = Movie.create! valid_attributes
          patch movie_url(movie), params: {movie: new_attributes}
          movie.reload
          expect(movie.original_title).to eq "Berk to the Future"
          expect(movie.translated_title).to eq "Berk to the Future"
          expect(movie.overview).to eq "This is a new overview"
          expect(movie.status).to eq "cancelled"
          expect(movie.runtime).to eq 110
          expect(movie.revenue).to eq 150000000
          expect(movie.budget).to eq 140000000
          expect(movie.homepage).to eq "https://github.com"
          expect(movie.imdb_id).to eq "tt0000001"
        end

        it "redirects to the movie" do
          movie = Movie.create! valid_attributes
          patch movie_url(movie), params: {movie: new_attributes}
          expect(response).to redirect_to(movie_url(movie))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          movie = Movie.create! valid_attributes
          patch movie_url(movie), params: {movie: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        movie = FactoryBot.create(:movie)
        patch movie_url(movie), params: {movie: new_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /people/:id/posters" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        movie = FactoryBot.create(:movie)
        get posters_movie_url(movie)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        movie = FactoryBot.create(:movie)
        get posters_movie_url(movie)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /people/:id/backgrounds" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        movie = FactoryBot.create(:movie)
        get backgrounds_movie_url(movie)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        movie = FactoryBot.create(:movie)
        get backgrounds_movie_url(movie)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /people/:id/logos" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        movie = FactoryBot.create(:movie)
        get logos_movie_url(movie)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        movie = FactoryBot.create(:movie)
        get logos_movie_url(movie)
        expect(response).to redirect_to new_session_path
      end
    end
  end
end
