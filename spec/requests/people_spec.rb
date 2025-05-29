require "rails_helper"

RSpec.describe "People", type: :request do
  let(:valid_attributes) {
    {
      alias: "Alias",
      biography: "Amazing bio",
      dob: "01-01-2025",
      dod: "01-01-2026",
      gender: "male",
      imdb_id: "nm0000000",
      known_for: "acting",
      original_name: "OG name",
      translated_name: "Translated name"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      dob: "invalid",
      dod: "invalid",
      original_name: nil,
      translated_name: nil
    })
  }

  describe "GET /people" do
    it "renders a successful response" do
      get people_url
      expect(response).to be_successful
    end
  end

  describe "GET /people/:id" do
    it "renders a successful response" do
      person = FactoryBot.create(:person)
      get person_url(person)
      expect(response).to be_successful
    end
  end

  describe "GET /people/new" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get new_person_url
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get new_person_url
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /edit" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        person = FactoryBot.create(:person)
        get edit_person_url(person)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        person = FactoryBot.create(:person)
        get edit_person_url(person)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /people" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new Person" do
          post people_url, params: {person: valid_attributes}
          person = Person.last
          expect(person.alias).to eq "Alias"
          expect(person.biography).to eq "Amazing bio"
          expect(person.dob).to eq Date.new(2025, 1, 1)
          expect(person.dod).to eq Date.new(2026, 1, 1)
          expect(person.gender).to eq "male"
          expect(person.imdb_id).to eq "nm0000000"
          expect(person.known_for).to eq "acting"
          expect(person.original_name).to eq "OG name"
          expect(person.translated_name).to eq "Translated name"
        end

        it "redirects to the created person's edit page" do
          post people_url, params: {person: valid_attributes}
          expect(response).to redirect_to(edit_person_url(Person.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Person" do
          expect {
            post people_url, params: {person: invalid_attributes}
          }.to change(Person, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post people_url, params: {person: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post people_url, params: {person: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /people/:id" do
    let(:new_attributes) {
      {
        alias: "New Alias",
        biography: "New Amazing bio",
        dob: "01-01-2027",
        dod: "01-01-2029",
        gender: "female",
        imdb_id: "nm0000001",
        known_for: "prod",
        original_name: "New OG name",
        translated_name: "New Translated name"
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
        it "updates the requested person" do
          person = Person.create! valid_attributes
          patch person_url(person), params: {person: new_attributes}
          person.reload
          expect(person.alias).to eq "New Alias"
          expect(person.biography).to eq "New Amazing bio"
          expect(person.dob).to eq Date.new(2027, 1, 1)
          expect(person.dod).to eq Date.new(2029, 1, 1)
          expect(person.gender).to eq "female"
          expect(person.imdb_id).to eq "nm0000001"
          expect(person.known_for).to eq "prod"
          expect(person.original_name).to eq "New OG name"
          expect(person.translated_name).to eq "New Translated name"
        end

        it "redirects to the person" do
          person = Person.create! valid_attributes
          patch person_url(person), params: {person: new_attributes}
          person.reload
          expect(response).to redirect_to(person_url(person))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          person = Person.create! valid_attributes
          patch person_url(person), params: {person: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        person = FactoryBot.create(:person)
        patch person_url(person), params: {person: new_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /people/:id/images" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        person = FactoryBot.create(:person)
        get images_person_url(person)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        person = FactoryBot.create(:person)
        get images_person_url(person)
        expect(response).to redirect_to new_session_path
      end
    end
  end
end
