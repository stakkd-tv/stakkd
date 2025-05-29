require 'rails_helper'

RSpec.describe "companies/edit", type: :view do
  let(:company) {
    Company.create!(
      description: "MyString",
      homepage: "MyString",
      name: "MyString"
    )
  }

  before(:each) do
    assign(:company, company)
  end

  it "renders the edit company form" do
    render

    assert_select "form[action=?][method=?]", company_path(company), "post" do

      assert_select "input[name=?]", "company[description]"

      assert_select "input[name=?]", "company[homepage]"

      assert_select "input[name=?]", "company[name]"
    end
  end
end
