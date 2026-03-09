require "rails_helper"

RSpec.describe "seasons/show", type: :view do
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:translated_name) { "The OG season" }

  before(:each) do
    def view.authenticated? = false
    @show = FactoryBot.create(
      :show,
      translated_title: "Translated Title",
      backgrounds:
    )
    @show.ordered_seasons.first.destroy # Destroy specials season, not needed for this test
    @season = FactoryBot.create(:season, show: @show, number: 1, posters:, overview: "This is overview", translated_name:)
    FactoryBot.create(
      :episode,
      number: 1,
      season: @season,
      original_air_date: Date.new(2023, 1, 1),
      runtime: 30,
      translated_name: "Pilot",
      backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/1280x720.png", "image/png")]
    )
    FactoryBot.create(
      :episode,
      number: 2,
      season: @season,
      original_air_date: Date.new(2023, 1, 2),
      runtime: 30,
      translated_name: "Ringtoneers",
      backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/1280x720.png", "image/png")]
    )
    gallery_presenter = Galleries::Presenter.new(@season)
    assign(:show, @show)
    assign(:season, @season)
    assign(:gallery_presenter, gallery_presenter)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/Season 1/)
    expect(rendered.scan("Season 1").count).to eq 1
    expect(rendered).to match(/The OG season/)
    expect(rendered).to match(/This is overview/)
    expect(rendered).to match(/January 01, 2023/)
    expect(rendered).to match(/1.0 hour/)
  end

  context "when name matches the potential name" do
    let(:translated_name) { "Season 1" }

    it "does not render the subtitle with the name" do
      render
      expect(rendered.scan("Season 1").count).to eq 1
    end
  end

  context "when the show has a background" do
    let(:backgrounds) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the background header" do
      render
      assert_select "img[class='w-full min-h-96 object-cover blur-xs'][src*='300x450.png']"
    end
  end

  context "when the season has a poster" do
    let(:posters) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Posters"
      assert_select "img[src*='300x450.png']", count: 2 # One for poster, the other in the gallery section
    end
  end

  it "renders all episodes" do
    render
    assert_select "p.font-domine", text: "Episode 1 - Pilot"
    assert_select "p.font-domine", text: "Episode 2 - Ringtoneers"
  end

  context "when there is a previous season" do
    before do
      FactoryBot.create(:season, show: @show, number: 0, posters:, overview: "This is overview", translated_name:)
    end

    it "renders the previous season link" do
      render
      assert_select "a[href='#{show_season_path(0, show_id: @show)}']", text: "Previous", count: 2
    end
  end

  context "when there is no previous season" do
    it "does not render perevious season link" do
      render
      assert_select "a", text: "Previous", count: 0
    end
  end

  context "when there is a next season" do
    before do
      FactoryBot.create(:season, show: @show, number: 2, posters:, overview: "This is overview", translated_name:)
    end

    it "renders the previous season link" do
      render
      assert_select "a[href='#{show_season_path(2, show_id: @show)}']", text: "Next", count: 2
    end
  end

  context "when there is no next season" do
    it "does not render perevious season link" do
      render
      assert_select "a", text: "Next", count: 0
    end
  end
end
