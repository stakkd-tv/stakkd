require "rails_helper"

RSpec.describe "/content_ratings", type: :request do
  let(:show) { FactoryBot.create(:show) }
  let(:certification) { FactoryBot.create(:certification) }
  let(:valid_attributes) {
    {
      certification_id: certification.id
    }
  }

  let(:invalid_attributes) {
    {
      certification_id: nil
    }
  }

  describe "GET /shows/:show_id/content_ratings" do
    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get show_content_ratings_path(show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get show_content_ratings_path(show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /shows/:show_id/content_ratings" do
    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new ContentRating" do
          post show_content_ratings_path(show), params: {content_rating: valid_attributes}
          content_rating = ContentRating.last
          expect(content_rating.show).to eq show
          expect(content_rating.certification).to eq certification
        end

        it "redirects to the index page" do
          post show_content_ratings_path(show), params: {content_rating: valid_attributes}
          expect(response).to redirect_to(show_content_ratings_path(show))
          expect(flash[:notice]).to eq("Successfully added certification.")
        end
      end

      context "with invalid parameters" do
        it "does not create a new ContentRating" do
          expect {
            post show_content_ratings_path(show), params: {content_rating: invalid_attributes}
          }.to change(ContentRating, :count).by(0)
        end

        it "redirects to the index page" do
          post show_content_ratings_path(show), params: {content_rating: invalid_attributes}
          expect(response).to redirect_to(show_content_ratings_path(show))
          expect(flash[:alert]).to eq("Certification could not be added.")
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post show_content_ratings_path(show), params: {content_rating: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "DELETE /shows/:show_id/content_ratings/:id" do
    context "when user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "destroys the requested content_rating" do
        content_rating = show.content_ratings.create! valid_attributes
        expect {
          delete show_content_rating_path(show, content_rating)
        }.to change(ContentRating, :count).by(-1)
      end

      it "redirects to the content_ratings list" do
        content_rating = show.content_ratings.create! valid_attributes
        delete show_content_rating_path(show, content_rating)
        expect(response).to redirect_to(show_content_ratings_path(show))
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        content_rating = show.content_ratings.create! valid_attributes
        delete show_content_rating_path(show, content_rating)
        expect(response).to redirect_to new_session_path
      end
    end
  end
end
