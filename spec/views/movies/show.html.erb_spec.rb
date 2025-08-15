require "rails_helper"

RSpec.describe "movies/show", type: :view do
  let(:country) { FactoryBot.create(:country) }
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:logos) { [] }
  let(:videos) { [] }
  let(:alternative_names) { {} }
  let(:release) { FactoryBot.create(:release, date: Date.new(2022, 1, 1)) }

  before(:each) do
    def view.authenticated? = false
    movie = FactoryBot.create(
      :movie,
      country:,
      original_title: "Original Title",
      translated_title: "Translated Title",
      overview: "This is overview",
      status: "released",
      runtime: 2,
      revenue: 99999999,
      budget: 100000000,
      homepage: "https://google.com",
      imdb_id: "tt0000000",
      posters:,
      backgrounds:,
      logos:,
      videos:,
      genres: [FactoryBot.create(:genre, name: "Action")],
      releases: [release]
    )
    assign(:movie, movie)
    gallery_presenter = Galleries::Presenter.new(movie)
    assign(:alternative_names, alternative_names)
    assign(:gallery_presenter, gallery_presenter)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/This is overview/)
    expect(rendered).to match(/Released/)
    expect(rendered).to match(/2 minutes/)
    expect(rendered).to match(/99,999,999/)
    expect(rendered).to match(/100,000,000/)
    assert_select "a[href='https://www.imdb.com/title/tt0000000/']"
    assert_select "a[href='https://google.com']"
  end

  it "renders the genres" do
    render
    assert_select "p.rounded-full", text: "Action"
  end

  context "when there is no release for the country" do
    it "does not render the release date" do
      render
      assert_select "p", text: "January 01, 2022", count: 0
    end
  end

  context "when there is a release for the country" do
    let(:release) { FactoryBot.create(:release, date: Date.new(2022, 1, 1), country:) }

    it "renders the release date" do
      render
      assert_select "p", text: "January 01, 2022"
    end
  end

  context "when there are alternative names" do
    let(:country) { FactoryBot.create(:country) }
    let(:names) { FactoryBot.build_list(:alternative_name, 1, type: "Test type") }
    let(:alternative_names) { {country => names} }

    it "renders the alternative names" do
      render
      assert_select "summary", text: "Alternative names:"
      assert_select "p", text: country.translated_name
      assert_select "p", text: names.first.name
      assert_select "p", text: names.first.type
    end
  end

  context "when the are no alternative names" do
    it "does not render the alternative names section" do
      render
      assert_select "summary", text: "Alternative names:", count: 0
    end
  end

  context "when the movie has a background" do
    let(:backgrounds) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the background header" do
      render
      assert_select "img[class='w-full min-h-96 object-cover blur-xs'][src*='300x450.png']"
    end

    it "renders the backgrounds section" do
      render
      assert_select "label", text: "Backgrounds"
      assert_select "img[src*='300x450.png']", count: 2
    end
  end

  context "when the movie has a poster" do
    let(:posters) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Posters"
      assert_select "img[src*='300x450.png']", count: 2 # One for poster, the other in the gallery section
    end
  end

  context "when the movie has a logo" do
    let(:logos) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Logos"
      assert_select "img[src*='300x450.png']", count: 1
    end
  end

  context "when the movie has a video" do
    let(:videos) { [FactoryBot.build(:video, thumbnail_url: "/example.png").tap { _1.save(validate: false) }] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Videos"
      assert_select "img[src='/example.png']", count: 1
    end
  end
end
