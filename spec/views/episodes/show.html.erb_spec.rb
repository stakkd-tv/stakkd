require "rails_helper"

RSpec.describe "episodes/show", type: :view do
  let(:posters) { [] }
  let(:backgrounds) { [] }

  before(:each) do
    def view.authenticated? = false
    @season = FactoryBot.create(:season, number: 1, posters:, overview: "This is overview", translated_name: "NAME")
    @show = @season.show
    @show.ordered_seasons.first.destroy # Destroy specials season, not needed for this test
    @episode = FactoryBot.create(
      :episode,
      number: 2,
      season: @season,
      original_air_date: Date.new(2023, 1, 1),
      runtime: 30,
      translated_name: "Pilot",
      backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/1280x720.png", "image/png")]
    )
    gallery_presenter = Galleries::Presenter.new(@season)
    assign(:show, @show)
    assign(:season, @season)
    assign(:gallery_presenter, gallery_presenter)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Episode 2/)
    expect(rendered).to match(/Pilot/)
    assert_select "a", text: "NAME"
    assert_select "a", text: @show.translated_title
  end

  context "when there is a previous episode" do
    before do
      FactoryBot.create(:episode, season: @season, number: 1)
    end

    it "renders the previous episode link" do
      render
      assert_select "a[href='#{show_season_episode_path(1, season_id: @season, show_id: @show)}']", text: "Previous"
    end
  end

  context "when there is no previous episode" do
    it "does not render perevious season link" do
      render
      assert_select "a", text: "Previous", count: 0
    end
  end

  context "when there is a next episode" do
    before do
      FactoryBot.create(:episode, season: @season, number: 3)
    end

    it "renders the next episode link" do
      render
      assert_select "a[href='#{show_season_episode_path(3, season_id: @season, show_id: @show)}']", text: "Next"
    end
  end

  context "when there is no next episode" do
    it "does not render next episode link" do
      render
      assert_select "a", text: "Next", count: 0
    end
  end
end
