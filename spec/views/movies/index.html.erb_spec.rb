require "rails_helper"

RSpec.describe "movies/index", type: :view do
  before(:each) do
    assign(:movies, [
      Movie.create!(
        budget: "9.99",
        homepage: "Homepage",
        imdb_id: "Imdb",
        original_title: "Original Title",
        overview: "Overview",
        revenue: "10.99",
        runtime: 2,
        status: "Status",
        tagline: "Tagline",
        translated_title: "Translated Title",
        title_kebab: "Title Kebab"
      ),
      Movie.create!(
        budget: "9.99",
        homepage: "Homepage",
        imdb_id: "Imdb",
        original_title: "Original Title",
        overview: "Overview",
        revenue: "10.99",
        runtime: 2,
        status: "Status",
        tagline: "Tagline",
        translated_title: "Translated Title",
        title_kebab: "Title Kebab"
      )
    ])
  end

  it "renders a list of movies" do
    render
    cell_selector = "div>p"
    assert_select cell_selector, text: Regexp.new("9.99"), count: 2
    assert_select cell_selector, text: Regexp.new("Homepage"), count: 2
    assert_select cell_selector, text: Regexp.new("Imdb"), count: 2
    assert_select cell_selector, text: Regexp.new("Original Title"), count: 2
    assert_select cell_selector, text: Regexp.new("Overview"), count: 2
    assert_select cell_selector, text: Regexp.new("10.99"), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Status"), count: 2
    assert_select cell_selector, text: Regexp.new("Tagline"), count: 2
    assert_select cell_selector, text: Regexp.new("Translated Title"), count: 2
    assert_select cell_selector, text: Regexp.new("Title Kebab"), count: 2
  end
end
