require "rails_helper"

RSpec.describe "genres/index", type: :view do
  before(:each) do
    assign(:genres, [
      Genre.create!(
        name: "Action"
      ),
      Genre.create!(
        name: "Adventure"
      )
    ])
  end

  it "renders a list of genres" do
    render
    cell_selector = "td"
    assert_select cell_selector, text: "Action", count: 1
    assert_select cell_selector, text: "Adventure", count: 1
  end
end
