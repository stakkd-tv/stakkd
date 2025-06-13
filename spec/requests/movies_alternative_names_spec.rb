require "rails_helper"

RSpec.describe "Movies AlternativeNames", type: :request do
  let(:movie) { FactoryBot.create(:movie) }
  let(:country) { FactoryBot.create(:country) }
  let(:valid_attributes) {
    {
      name: "Test name",
      type: "Test type",
      country_id: country.id
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      name: nil,
      country_id: nil
    })
  }

  describe "GET /movies/:movie_id/alternative_names" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get movie_alternative_names_path(movie_id: movie)
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
        get movie_alternative_names_path(movie_id: movie)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /movies/:movie_id/alternative_names" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post movie_alternative_names_path(movie_id: movie), params: {alternative_name: valid_attributes}
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
        it "creates an alternative name" do
          post movie_alternative_names_path(movie_id: movie), params: {alternative_name: valid_attributes}
          alternative_name = AlternativeName.last
          expect(alternative_name.record).to eq movie
          expect(alternative_name.name).to eq "Test name"
          expect(alternative_name.type).to eq "Test type"
          expect(alternative_name.country).to eq country
        end

        it "redirects to the alternative names index path" do
          post movie_alternative_names_path(movie_id: movie), params: {alternative_name: valid_attributes}
          expect(response).to redirect_to movie_alternative_names_path(movie_id: movie)
        end
      end

      context "with invalid params" do
        it "does not create an alternative name" do
          post movie_alternative_names_path(movie_id: movie), params: {alternative_name: invalid_attributes}
          expect(AlternativeName.count).to eq 0
        end

        it "redirects to the alternative names index path with a flash alert" do
          post movie_alternative_names_path(movie_id: movie), params: {alternative_name: invalid_attributes}
          expect(response).to redirect_to movie_alternative_names_path(movie_id: movie)
          expect(flash[:alert]).to eq "Could not add that name. A name and country must be specified."
        end
      end
    end
  end

  describe "PATCH /movies/:movie_id/alternative_names/:id" do
    let(:new_country) { FactoryBot.create(:country) }
    let(:new_attributes) {
      {
        name: "New name",
        type: "New type",
        country_id: new_country.id
      }
    }

    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        alternative_name = movie.alternative_names.create!(valid_attributes)
        patch movie_alternative_name_path(alternative_name, movie_id: movie), params: {alternative_name: new_attributes}
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
        it "updates the alternative name" do
          alternative_name = movie.alternative_names.create!(valid_attributes)
          patch movie_alternative_name_path(alternative_name, movie_id: movie), params: {alternative_name: new_attributes}
          alternative_name.reload
          expect(alternative_name.name).to eq "New name"
          expect(alternative_name.type).to eq "New type"
          expect(alternative_name.country).to eq new_country
        end

        it "renders json" do
          alternative_name = movie.alternative_names.create!(valid_attributes)
          patch movie_alternative_name_path(alternative_name, movie_id: movie), params: {alternative_name: new_attributes}
          expect(response).to be_successful
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => true
          })
        end
      end

      context "with invalid params" do
        it "does not update the alternative name" do
          alternative_name = movie.alternative_names.create!(valid_attributes)
          patch movie_alternative_name_path(alternative_name, movie_id: movie), params: {alternative_name: invalid_attributes}
          alternative_name.reload
          expect(alternative_name.name).to eq "Test name"
          expect(alternative_name.type).to eq "Test type"
          expect(alternative_name.country).to eq country
        end

        it "renders json with errors" do
          alternative_name = movie.alternative_names.create!(valid_attributes)
          patch movie_alternative_name_path(alternative_name, movie_id: movie), params: {alternative_name: invalid_attributes}
          expect(response.status).to eq 422
          json = JSON.parse(response.body)
          expect(json).to eq({
            "success" => false,
            "errors" => [
              {"country" => ["Country must exist"]},
              {"name" => ["Name can't be blank"]}
            ]
          })
        end
      end
    end
  end
end
