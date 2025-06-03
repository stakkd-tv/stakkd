require "rails_helper"

RSpec.describe "companies/index", type: :view do
  before(:each) do
    assign(:companies, [
      Company.create!(
        description: "Description",
        homepage: "Homepage",
        name: "Name"
      ),
      Company.create!(
        description: "Description",
        homepage: "Homepage",
        name: "Name"
      )
    ])
  end

  it "renders a list of companies" do
    render
    cell_selector = "div>p"
    assert_select cell_selector, text: Regexp.new("Description"), count: 2
    assert_select cell_selector, text: Regexp.new("Homepage"), count: 2
    assert_select cell_selector, text: Regexp.new("Name"), count: 2
  end
end
