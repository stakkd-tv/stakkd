require "rails_helper"

RSpec.describe "Franchises", type: :request do
  let(:valid_attributes) {
    {
      original_title: "Back to the Future",
      translated_title: "Back to the Future",
      overview: "This is an overview",
      homepage: "https://google.com"
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      translated_title: nil,
      original_title: nil
    })
  }

  describe "GET /franchises" do
    it "renders a successful response" do
      get franchises_path
      expect(response).to be_successful
    end
  end

  describe "GET /franchises/:id" do
    it "renders a successful response" do
      franchise = FactoryBot.create(:franchise)
      get franchise_path(franchise)
      expect(response).to be_successful
    end
  end

  describe "GET /franchises/new" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get new_franchise_url
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get new_franchise_url
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /franchises/:id/edit" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        franchise = FactoryBot.create(:franchise)
        get edit_franchise_url(franchise)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        franchise = FactoryBot.create(:franchise)
        get edit_franchise_url(franchise)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /franchises" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new Franchise" do
          post franchises_url, params: {franchise: valid_attributes}
          franchise = Franchise.last
          expect(franchise.original_title).to eq "Back to the Future"
          expect(franchise.translated_title).to eq "Back to the Future"
          expect(franchise.overview).to eq "This is an overview"
          expect(franchise.homepage).to eq "https://google.com"
        end

        it "redirects to the created franchise's edit page" do
          post franchises_url, params: {franchise: valid_attributes}
          expect(response).to redirect_to(edit_franchise_url(Franchise.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new franchise" do
          expect {
            post franchises_path, params: {franchise: invalid_attributes}
          }.to change(Franchise, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post franchises_path, params: {franchise: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post franchises_path, params: {franchise: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /franchises/:id" do
    let(:new_attributes) {
      {
        original_title: "Berk to the Future",
        translated_title: "Berk to the Future",
        overview: "This is a new overview",
        homepage: "https://github.com"
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
        it "updates the requested franchise" do
          franchise = Franchise.create! valid_attributes
          patch franchise_url(franchise), params: {franchise: new_attributes}
          franchise.reload
          expect(franchise.original_title).to eq "Berk to the Future"
          expect(franchise.translated_title).to eq "Berk to the Future"
          expect(franchise.overview).to eq "This is a new overview"
          expect(franchise.homepage).to eq "https://github.com"
        end

        it "redirects to the franchise" do
          franchise = Franchise.create! valid_attributes
          patch franchise_url(franchise), params: {franchise: new_attributes}
          expect(response).to redirect_to(franchise_url(franchise))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          franchise = Franchise.create! valid_attributes
          patch franchise_url(franchise), params: {franchise: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        franchise = FactoryBot.create(:franchise)
        patch franchise_url(franchise), params: {franchise: new_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end
end
