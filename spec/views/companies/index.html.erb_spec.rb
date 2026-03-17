require "rails_helper"

RSpec.describe "companies/index", type: :view do
  before(:each) do
    @c1 = FactoryBot.create(:company, name: "YouTube")
    @c2 = FactoryBot.create(:company, name: "Bruh")
    assign(:companies, Company.all.paginate(page: 1, per_page: 10))
  end

  it "renders a new company link" do
    render
    assert_select "a[href='#{new_company_path}']"
  end

  it "renders a list of companies" do
    render
    assert_select "h3", text: "YouTube"
    assert_select "h3", text: "Bruh"
    assert_select "a[href='#{company_path(@c1)}']"
    assert_select "a[href='#{company_path(@c2)}']"
  end
end
