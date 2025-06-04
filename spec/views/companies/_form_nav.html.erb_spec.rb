require "rails_helper"

RSpec.describe "companies/_form_nav", type: :view do
  context "when person is persisted" do
    it "renders the nav" do
      def view.action_name = "edit"
      company = FactoryBot.create(:company)
      render "companies/form_nav", company: company
      assert_select "a[href='#{edit_company_path(company)}'][data-active='true']"
      assert_select "a[href='#{logos_company_path(company)}'][data-active='false']"
    end
  end

  context "when company is not persisted" do
    it "does not render the nav" do
      company = FactoryBot.build(:company)
      render "companies/form_nav", company: company
      expect(rendered).to eq ""
    end
  end
end
