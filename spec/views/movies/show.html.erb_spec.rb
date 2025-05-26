require "rails_helper"

RSpec.describe "movies/show", type: :view do
  before(:each) do
    assign(:movie, Movie.create!(
      budget: "9.99",
      homepage: "Homepage",
      imdb_id: "Imdb",
      original_title: "Original Title",
      overview: "Overview",
      revenue: "9.99",
      runtime: 2,
      status: "Status",
      tagline: "Tagline",
      translated_title: "Translated Title",
      title_kebab: "Title Kebab"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Homepage/)
    expect(rendered).to match(/Imdb/)
    expect(rendered).to match(/Original Title/)
    expect(rendered).to match(/Overview/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/Tagline/)
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/Title Kebab/)
  end
end
