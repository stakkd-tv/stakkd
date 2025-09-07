require "rails_helper"

RSpec.describe "Shows CompanyAssignments", type: :request do
  let(:show) { FactoryBot.create(:show) }
  let(:company) { FactoryBot.create(:company) }
  let(:valid_attributes) {
    {
      company_id: company.id
    }
  }

  let(:invalid_attributes) {
    valid_attributes.merge({
      company_id: nil
    })
  }

  describe "GET /shows/:show_id/company_assignments" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        get show_company_assignments_path(show_id: show)
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
        get show_company_assignments_path(show_id: show)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /shows/:show_id/company_assignments" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        post show_company_assignments_path(show_id: show), params: {company_assignment: valid_attributes}
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
        it "creates an company assignment" do
          post show_company_assignments_path(show_id: show), params: {company_assignment: valid_attributes}
          company_assignment = CompanyAssignment.last
          expect(company_assignment.record).to eq show
          expect(company_assignment.company).to eq company
        end

        it "redirects to the company assignments index path" do
          post show_company_assignments_path(show_id: show), params: {company_assignment: valid_attributes}
          expect(response).to redirect_to show_company_assignments_path(show_id: show)
        end
      end

      context "with invalid params" do
        it "does not create a company assignment" do
          post show_company_assignments_path(show_id: show), params: {company_assignment: invalid_attributes}
          expect(CompanyAssignment.count).to eq 0
        end

        it "redirects to the company assignments index path with a flash alert" do
          post show_company_assignments_path(show_id: show), params: {company_assignment: invalid_attributes}
          expect(response).to redirect_to show_company_assignments_path(show_id: show)
          expect(flash[:alert]).to eq "Could not add company. You must choose a company from the dropdown and can't assign the same company twice."
        end
      end
    end
  end

  describe "DELETE /shows/:show_id/company_assignments/:id" do
    context "when user is not signed in" do
      it "redirects to the user sign in page" do
        company_assignment = show.company_assignments.create!(valid_attributes)
        delete show_company_assignment_path(company_assignment, show_id: show)
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

      it "deletes the company assignment" do
        company_assignment = show.company_assignments.create!(valid_attributes)
        delete show_company_assignment_path(company_assignment, show_id: show)
        expect(CompanyAssignment.count).to eq 0
      end

      it "renders no content" do
        company_assignment = show.company_assignments.create!(valid_attributes)
        delete show_company_assignment_path(company_assignment, show_id: show)
        expect(response).to be_no_content
      end
    end
  end
end
