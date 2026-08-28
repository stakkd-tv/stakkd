require "rails_helper"

RSpec.describe "movies/show", type: :view do
  let(:country) { FactoryBot.create(:country) }
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:logos) { [] }
  let(:videos) { [] }
  let(:alternative_names) { {} }
  let(:release) { FactoryBot.create(:release, date: Date.new(2022, 1, 1)) }
  let(:imdb_id) { nil }
  let(:has_franchise) { false }
  let(:has_release) { true }
  let(:watch_status) { :not_consumed }
  let(:stacks_with_previews) { {} }
  let(:stacks_next_page) { nil }

  before(:each) do
    def view.authenticated? = false
    def view.current_user = nil
    @movie = FactoryBot.create(
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
      imdb_id:,
      posters:,
      backgrounds:,
      logos:,
      videos:,
      genres: [FactoryBot.create(:genre, name: "Action")],
      releases: [release]
    )
    FactoryBot.create(:cast_member, record: @movie, person: FactoryBot.build(:person, translated_name: "John Doe"), character: "Bob")
    if has_release
      cert = FactoryBot.create(:certification, country: @movie.country, code: "ABCODE")
      release1 = FactoryBot.create(:release, movie: @movie, type: Release::THEATRICAL, certification: cert, date: Date.new(2022, 2, 1), note: "This is a note")
    end
    gallery_presenter = Galleries::Presenter.new(@movie)
    if has_franchise
      franchise = FactoryBot.create(:franchise, translated_title: "Franchise Title")
      FactoryBot.create(:franchise_item, record: @movie, franchise:)
    end
    assign(:movie, @movie)
    assign(:alternative_names, alternative_names)
    assign(:gallery_presenter, gallery_presenter)
    assign(:release_dates_for_country, [release1])
    assign(:cast_members, CastMembers::Movie.new(@movie).cast_members)
    assign(:watch_status, watch_status)
    assign(:stacks_with_previews, stacks_with_previews)
    assign(:stacks_next_page, stacks_next_page)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/This is overview/)
    expect(rendered).to match(/Released/)
    expect(rendered).to match(/2m/)
    expect(rendered).to match(/99,999,999/)
    expect(rendered).to match(/100,000,000/)
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
    assert_select "a[href='#{cast_movie_path(@movie)}']"
  end

  it "renders the add to history dialog" do
    render
    assert_select "dialog[data-controller='history-dialog']"
  end

  it "renders the add to stack dialog" do
    render
    assert_select "dialog[data-controller='stack-dialog']"
  end

  it "renders the add to history button when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    render
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_movie_path(@movie)}']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_movie_path(@movie)}'][disabled]", count: 0
  end

  it "renders the add to stack button when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_movie_path(@movie)}']"
  end

  it "does not render the add to stack button when not authenticated" do
    allow(view).to receive(:authenticated?).and_return(false)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_movie_path(@movie)}']", count: 0
  end

  context "when the movie is consumed" do
    let(:watch_status) { :consumed }

    it "renders the add to history button in a disabled state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-status='consumed']"
    end
  end

  context "when the movies is not consumed" do
    let(:watch_status) { :not_consumed }

    it "renders the add to history button" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-status='not_consumed']"
    end
  end

  context "when the movie has no release date" do
    let(:has_release) { false }

    it "renders the add to history button in a disabled state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_movie_path(@movie)}'][disabled]", count: 1
    end
  end

  context "when there is no release for the country" do
    it "does not render the release date" do
      render
      assert_select "p", text: "January 01, 2022", count: 0
    end
  end

  it "displays releases for the country" do
    render
    assert_select "td", text: "2022-02-01"
    assert_select "td", text: "Theatrical"
    assert_select "td", text: "ABCODE"
    assert_select "td", text: "This is a note"
  end

  context "when there is a release for the country" do
    let(:release) { FactoryBot.create(:release, date: Date.new(2022, 1, 1), country:) }

    it "renders the release date" do
      render
      assert_select "p", text: "January 01, 2022"
    end
  end

  context "when the movie has directors" do
    before do
      job = FactoryBot.create(:job, name: Job::DIRECTOR)
      @person = FactoryBot.create(:person, translated_name: "John Doe")
      FactoryBot.create(:crew_member, job:, person: @person, record: @movie)
      @person2 = FactoryBot.create(:person, translated_name: "Chris Doe")
      FactoryBot.create(:crew_member, job:, person: @person2, record: @movie)
    end

    it "renders the directors" do
      render
      assert_select "p", text: "Directors:"
      assert_select "a", text: "John Doe"
      assert_select "a", text: "Chris Doe"
    end
  end

  context "when the movie has no directors" do
    it "does not render the directors" do
      render
      assert_select "p", text: "Directors:", count: 0
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

  context "when the movie has a franchise" do
    let(:has_franchise) { true }

    it "renders the franchise title" do
      render
      assert_select "p", text: "PART OF THE"
      assert_select "p", text: "Franchise Title"
      assert_select "p", text: "FRANCHISE"
      assert_select "a[href='#{franchise_path(Franchise.last)}']"
    end
  end

  context "when the movie does not have a franchise" do
    let(:has_franchise) { false }

    it "does not render the franchise cta" do
      render
      assert_select "p", text: "PART OF THE", count: 0
      assert_select "p", text: "FRANCHISE", count: 0
    end
  end

  context "when the movie has some stacks" do
    let(:stack) { FactoryBot.create(:stack, name: "Amazing Stack") }
    let(:stack_items) { [FactoryBot.create(:stack_item, item: @movie)] }
    let(:stacks_with_previews) { {stack => stack_items} }

    it "renders the top stacks section" do
      render
      assert_select "h4", text: "Top stacks:"
      assert_select "turbo-frame[id='top_stacks']" do
        assert_select "h6", text: "Amazing Stack"
      end
    end

    context "when more stacks can be loaded" do
      let(:stacks_next_page) { 2 }

      it "renders the load more button" do
        render
        assert_select "turbo-frame[id='load_more_top_stacks']" do
          assert_select "a[href='#{load_more_top_stacks_movie_path(@movie, page: 2)}']"
        end
      end
    end

    context "when no more stacks can be loaded" do
      it "does not render the load more button" do
        render
        assert_select "turbo-frame[id='load_more_top_stacks']", count: 0
      end
    end
  end

  context "when the movies does not have any stacks" do
    let(:stacks_with_previews) { {} }

    it "does not render the top stacks section" do
      render
      assert_select "h4", text: "Top stacks:", count: 0
    end
  end
end
