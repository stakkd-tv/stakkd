require "rails_helper"

RSpec.describe "shows/show", type: :view do
  let(:country) { FactoryBot.create(:country) }
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:logos) { [] }
  let(:videos) { [] }
  let(:alternative_names) { {} }
  let(:imdb_id) { nil }
  let(:has_franchise) { false }

  before(:each) do
    def view.authenticated? = false
    @show = FactoryBot.create(
      :show,
      country:,
      original_title: "Original Title",
      translated_title: "Translated Title",
      overview: "This is overview",
      status: "ended",
      type: "series",
      homepage: "https://google.com",
      imdb_id:,
      posters:,
      backgrounds:,
      logos:,
      videos:,
      genres: [FactoryBot.create(:genre, name: "Action")]
    )
    FactoryBot.create(:cast_member, record: @show, person: FactoryBot.build(:person, translated_name: "John Doe"), character: "Bob")
    gallery_presenter = Galleries::Presenter.new(@show)
    if has_franchise
      franchise = FactoryBot.create(:franchise, translated_title: "Franchise Title")
      FactoryBot.create(:franchise_item, record: @show, franchise:)
    end
    assign(:show, @show)
    assign(:alternative_names, alternative_names)
    assign(:gallery_presenter, gallery_presenter)
    assign(:cast_members, CastMembers::Show.new(@show).cast_members)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/This is overview/)
    expect(rendered).to match(/Ended/)
    expect(rendered).to match(/Series/)
    assert_select "a[href='https://google.com']"
  end

  it "renders the genres" do
    render
    assert_select "a.rounded-full", text: "Action"
  end

  it "renders the cast members" do
    render
    assert_select "p", text: "John Doe"
    assert_select "small", text: "Bob"
    assert_select "a[href='#{cast_show_path(@show)}']"
  end

  it "renders the seasons" do
    season = FactoryBot.create(:season, show: @show, number: 1, translated_name: "Season 1")
    FactoryBot.create(:episode, season:)
    render
    assert_select "#seasons" do
      assert_select "h4", text: "1 Season"
      assert_select "p", text: "Specials"
      assert_select "small", text: "0 episodes"
      assert_select "a[href='#{show_season_path(@show.ordered_seasons.first, show_id: @show)}']"
      assert_select "p", text: "Season 1"
      assert_select "small", text: "1 episode"
      assert_select "a[href='#{show_season_path(season, show_id: @show)}']"
    end
  end

  it "renders the add to history dialog" do
    render
    assert_select "dialog[data-controller='history-dialog']"
  end

  it "renders the add to history button when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    FactoryBot.create(:season, :with_premiere_date, show: @show)
    render
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_path(@show)}']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_path(@show)}'][disabled]", count: 0
  end

  context "when the show has no release date" do
    it "renders the add to history button in a disabled state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_path(@show)}'][disabled]", count: 1
    end
  end

  context "when there are seasons" do
    it "renders the add to history buttons for each season when authenticated" do
      allow(view).to receive(:authenticated?).and_return(true)
      season = FactoryBot.create(:season, show: @show)
      render
      assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_path(@show, season)}']"
    end
  end

  context "when the show has creators" do
    before do
      job = FactoryBot.create(:job, name: Job::CREATOR)
      @person = FactoryBot.create(:person, translated_name: "John Doe")
      FactoryBot.create(:crew_member, job:, person: @person, record: @show)
      @person2 = FactoryBot.create(:person, translated_name: "Chris Doe")
      FactoryBot.create(:crew_member, job:, person: @person2, record: @show)
    end

    it "renders the creators" do
      render
      assert_select "p", text: "Creators:"
      assert_select "a", text: "John Doe"
      assert_select "a", text: "Chris Doe"
    end
  end

  context "when the show has no creators" do
    it "does not render the creators" do
      render
      assert_select "p", text: "Creators:", count: 0
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

  context "when the show has a background" do
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

  context "when the show has a poster" do
    let(:posters) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Posters"
      assert_select "img[src*='300x450.png']", count: 2 # One for poster, the other in the gallery section
    end
  end

  context "when the show has a logo" do
    let(:logos) { [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Logos"
      assert_select "img[src*='300x450.png']", count: 1
    end
  end

  context "when the show has a video" do
    let(:videos) { [FactoryBot.build(:video, thumbnail_url: "/example.png").tap { it.save(validate: false) }] }

    it "renders the posters section" do
      render
      assert_select "label", text: "Videos"
      assert_select "img[src='/example.png']", count: 1
    end
  end

  context "when there is an IMDb URL" do
    let(:imdb_id) { "tt1234567" }

    it "renders the IMDb link" do
      render
      assert_select "a.link-imdb[href='https://www.imdb.com/title/#{imdb_id}/']"
    end
  end

  context "when there is no IMDb URL" do
    it "does not render the IMDb link" do
      render
      assert_select "a.link-imdb", count: 0
    end
  end

  context "when the show has a franchise" do
    let(:has_franchise) { true }

    it "renders the franchise title" do
      render
      assert_select "p", text: "PART OF THE"
      assert_select "p", text: "Franchise Title"
      assert_select "p", text: "FRANCHISE"
      assert_select "a[href='#{franchise_path(Franchise.last)}']"
    end
  end

  context "when the show does not have a franchise" do
    let(:has_franchise) { false }

    it "does not render the franchise cta" do
      render
      assert_select "p", text: "PART OF THE", count: 0
      assert_select "p", text: "FRANCHISE", count: 0
    end
  end
end
