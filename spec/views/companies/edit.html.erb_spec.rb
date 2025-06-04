require "rails_helper"

RSpec.describe "companies/edit", type: :view do
  let(:company) { FactoryBot.create(:company) }

  before(:each) do
    assign(:company, company)
  end

  it "renders the edit company form" do
    render

    assert_select "form[action='#{company_path(company)}'][method='post']" do
      assert_select "input[name='company[name]']"
      assert_select "textarea[name='company[description]']"
      assert_select "input[name='company[homepage]']"
    end
  end
end
