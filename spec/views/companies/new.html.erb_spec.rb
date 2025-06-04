require "rails_helper"

RSpec.describe "companies/new", type: :view do
  before(:each) do
    assign(:company, FactoryBot.build(:company))
  end

  it "renders new company form" do
    render

    assert_select "form[action='#{companies_path}'][method='post']" do
      assert_select "input[name='company[name]']"
      assert_select "textarea[name='company[description]']"
      assert_select "input[name='company[homepage]']"
      assert_select "select[name='company[country_id]']"
    end
  end
end
