require "rails_helper"

RSpec.describe "/shows", type: :request do
  let(:country) { FactoryBot.create(:country) }
  let(:language) { FactoryBot.create(:language) }
  let(:valid_attributes) {
    {
      language_id: language.id,
      country_id: country.id,
      original_title: "Back to the Future",
      translated_title: "Back to the Future",
      overview: "This is an overview",
      status: Show::RETURNING,
      homepage: "https://google.com",
      imdb_id: "tt0000000",
      type: Show::SERIES
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      language_id: nil,
      country_id: nil,
      translated_title: nil,
      original_title: nil,
      status: "invalid",
      type: "invalid"
    })
  }

  describe "GET /shows" do
    it "renders a successful response" do
      Show.create! valid_attributes
      get shows_url
      expect(response).to be_successful
    end
  end

  describe "GET /shows/:id" do
    it "renders a successful response" do
      show = FactoryBot.create(:show)
      get show_url(show)
      expect(response).to be_successful
    end
  end

  describe "GET /shows/new" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get new_show_url
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get new_show_url
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:id/edit" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        show = FactoryBot.create(:show)
        get edit_show_url(show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        show = FactoryBot.create(:show)
        get edit_show_url(show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /shows" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new Show" do
          post shows_url, params: {show: valid_attributes}
          show = Show.last
          expect(show.language).to eq language
          expect(show.country).to eq country
          expect(show.original_title).to eq "Back to the Future"
          expect(show.translated_title).to eq "Back to the Future"
          expect(show.overview).to eq "This is an overview"
          expect(show.status).to eq Show::RETURNING
          expect(show.type).to eq Show::SERIES
          expect(show.homepage).to eq "https://google.com"
          expect(show.imdb_id).to eq "tt0000000"
        end

        it "redirects to the created show's edit page" do
          post shows_url, params: {show: valid_attributes}
          expect(response).to redirect_to(edit_show_url(Show.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new show" do
          expect {
            post shows_path, params: {show: invalid_attributes}
          }.to change(Show, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post shows_path, params: {show: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post shows_path, params: {show: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /shows/:id" do
    let(:new_attributes) {
      {
        original_title: "Berk to the Future",
        translated_title: "Berk to the Future",
        overview: "This is a new overview",
        status: "ended",
        type: "documentary",
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
        it "updates the requested show" do
          show = Show.create! valid_attributes
          patch show_url(show), params: {show: new_attributes}
          show.reload
          expect(show.original_title).to eq "Berk to the Future"
          expect(show.translated_title).to eq "Berk to the Future"
          expect(show.overview).to eq "This is a new overview"
          expect(show.status).to eq "ended"
          expect(show.type).to eq "documentary"
          expect(show.homepage).to eq "https://github.com"
          expect(show.imdb_id).to eq "tt0000001"
        end

        it "redirects to the show" do
          show = Show.create! valid_attributes
          patch show_url(show), params: {show: new_attributes}
          expect(response).to redirect_to(show_url(show))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          show = Show.create! valid_attributes
          patch show_url(show), params: {show: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        show = FactoryBot.create(:show)
        patch show_url(show), params: {show: new_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:id/posters" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        show = FactoryBot.create(:show)
        get posters_show_url(show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        show = FactoryBot.create(:show)
        get posters_show_url(show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:id/backgrounds" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        show = FactoryBot.create(:show)
        get backgrounds_show_url(show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        show = FactoryBot.create(:show)
        get backgrounds_show_url(show)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /shows/:id/logos" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        show = FactoryBot.create(:show)
        get logos_show_url(show)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        show = FactoryBot.create(:show)
        get logos_show_url(show)
        expect(response).to redirect_to new_session_path
      end
    end
  end
end
