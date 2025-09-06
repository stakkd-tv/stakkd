require "rails_helper"

RSpec.describe "shows/show", type: :view do
  before(:each) do
    assign(:show, FactoryBot.create(
      :show,
      homepage: "Homepage",
      imdb_id: "Imdb",
      original_title: "Original Title",
      overview: "Overview",
      runtime: 2,
      status: "ended",
      translated_title: "Translated Title",
      title_kebab: "Title Kebab",
      type: "series"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Homepage/)
    expect(rendered).to match(/Imdb/)
    expect(rendered).to match(/Original Title/)
    expect(rendered).to match(/Overview/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/ended/)
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/Title Kebab/)
    expect(rendered).to match(/series/)
  end
end
