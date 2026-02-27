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
    @season = FactoryBot.create(:season, show: @show, number: 1, posters:, overview: "This is overview", translated_name:)
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
    expect(rendered).to match(/TODO: First episode air date/)
    expect(rendered).to match(/TODO: Sum of all episode in season/)
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
end
