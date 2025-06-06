require "rails_helper"

RSpec.describe "countries/index", type: :view do
  before(:each) do
    assign(:countries, [
      Country.create!(
        code: "EN",
        translated_name: "Translated Name",
        original_name: "Original Name"
      ),
      Country.create!(
        code: "AR",
        translated_name: "Translated Name",
        original_name: "Original Name"
      )
    ])
  end

  it "renders a list of countries" do
    render
    cell_selector = "td"
    assert_select cell_selector, text: "EN", count: 1
    assert_select cell_selector, text: "AR", count: 1
    assert_select cell_selector, text: "Translated Name", count: 2
    assert_select cell_selector, text: "Original Name", count: 2
  end
end
