require "rails_helper"

RSpec.describe "Movies Keywords", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
  let(:valid_attributes) {
    {
      tag: "Hello there"
    }
  }

  describe "GET /movies/:movie_id/keywords" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get movie_keywords_path(movie_id: movie)
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
        get movie_keywords_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/keywords" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_keywords_path(movie_id: movie), params: valid_attributes
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
        it "adds keywords" do
          post movie_keywords_path(movie_id: movie), params: valid_attributes
          expect(movie.reload.keyword_list).to eq ["Hello there"]
        end

        it "redirects to the keywords index path" do
          post movie_keywords_path(movie_id: movie), params: valid_attributes
          expect(response).to redirect_to movie_keywords_path(movie_id: movie)
        end
      end
    end
  end

  describe "DELETE /movies/:movie_id/keywords/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        movie.keyword_list.add("hello there")
        movie.save
        tagging = movie.keyword_taggings.first
        delete movie_keyword_path(tagging, movie_id: movie)
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
        movie.keyword_list.add("hello there")
        movie.save
        tagging = movie.keyword_taggings.first
        delete movie_keyword_path(tagging, movie_id: movie)
        expect(movie.reload.keyword_list).to eq []
      end

      it "renders no content" do
        movie.keyword_list.add("hello there")
        movie.save
        tagging = movie.keyword_taggings.first
        delete movie_keyword_path(tagging, movie_id: movie)
        expect(response).to be_no_content
      end
    end
  end
end
