require "rails_helper"

RSpec.describe "Companies", type: :request do
  let(:country) { FactoryBot.create(:country) }
  let(:valid_attributes) {
    {
      description: "The sussy corporation",
      homepage: "https://example.com",
      name: "Amogus Inc",
      country_id: country.id
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      name: nil,
      country_id: nil
    })
  }

  describe "GET /companies" do
    it "renders a successful response" do
      get companies_url
      expect(response).to be_successful
    end
  end

  describe "GET /companies/:id" do
    it "renders a successful response" do
      company = FactoryBot.create(:company)
      get company_url(company)
      expect(response).to be_successful
    end
  end

  describe "GET /companies/new" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        get new_company_url
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        get new_company_url
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /companies/:id/edit" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        company = FactoryBot.create(:company)
        get edit_company_url(company)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        company = FactoryBot.create(:company)
        get edit_company_url(company)
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /companies" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      context "with valid parameters" do
        it "creates a new company" do
          post companies_url, params: {company: valid_attributes}
          company = Company.last
          expect(company.name).to eq "Amogus Inc"
          expect(company.description).to eq "The sussy corporation"
          expect(company.homepage).to eq "https://example.com"
        end

        it "redirects to the created companies edit page" do
          post companies_url, params: {company: valid_attributes}
          expect(response).to redirect_to(edit_company_url(Company.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new company" do
          expect {
            post companies_url, params: {company: invalid_attributes}
          }.to change(Company, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post companies_url, params: {company: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        post companies_url, params: {company: valid_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /companies/:id" do
    let(:new_attributes) {
      {
        name: "New Name",
        description: "New Desc",
        homepage: "new.com"
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
        it "updates the requested company" do
          company = Company.create! valid_attributes
          patch company_url(company), params: {company: new_attributes}
          company.reload
          expect(company.name).to eq "New Name"
          expect(company.description).to eq "New Desc"
          expect(company.homepage).to eq "new.com"
        end

        it "redirects to the company" do
          company = Company.create! valid_attributes
          patch company_url(company), params: {company: new_attributes}
          company.reload
          expect(response).to redirect_to(company_url(company))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          company = Company.create! valid_attributes
          patch company_url(company), params: {company: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        company = FactoryBot.create(:company)
        patch company_url(company), params: {company: new_attributes}
        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /companies/:id/logos" do
    context "when the user is signed in" do
      before do
        user = FactoryBot.create(:user)
        session = Session.new(user:)
        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
      end

      it "renders a successful response" do
        company = FactoryBot.create(:company)
        get logos_company_url(company)
        expect(response).to be_successful
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign in page" do
        company = FactoryBot.create(:company)
        get logos_company_url(company)
        expect(response).to redirect_to new_session_path
      end
    end
  end
end
