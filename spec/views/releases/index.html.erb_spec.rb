require "rails_helper"

RSpec.describe "releases/index", type: :view do
  let(:movie) { FactoryBot.create(:movie) }

  before(:each) do
    cert = FactoryBot.create(:certification, country: movie.country, code: "ABCODE")
    release = FactoryBot.create(:release, movie:, type: Release::THEATRICAL, certification: cert, date: Date.new(2022, 2, 1), note: "This is a note")
    assign(:movie, movie)
    assign(:countries_with_counts, [{name: movie.country.translated_name, code: movie.country.code, count: 1}])
    assign(:overall_count, 1)
    assign(:releases_grouped_by_country, {movie.country => [release]})
  end

  it "renders the releases" do
    render
    assert_select "td", text: "2022-02-01"
    assert_select "td", text: "Theatrical"
    assert_select "td", text: "ABCODE"
    assert_select "td", text: "This is a note"
  end

  it "renders the counts" do
    render
    assert_select "a", text: "All (1)"
    assert_select "a", text: "#{movie.country.translated_name} (1)"
  end
end
