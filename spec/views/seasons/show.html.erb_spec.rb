require "rails_helper"

RSpec.describe "seasons/show", type: :view do
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:translated_name) { "The OG season" }
  let(:has_episodes) { true }
  let(:watch_status) { :not_consumed }
  let(:stacks_with_previews) { {} }
  let(:stacks_next_page) { nil }

  before(:each) do
    def view.authenticated? = false
    def view.current_user = nil
    @show = FactoryBot.create(
      :show,
      translated_title: "Translated Title",
      backgrounds:
    )
    @show.ordered_seasons.first.destroy # Destroy specials season, not needed for this test
    @season = FactoryBot.create(:season, show: @show, number: 1, posters:, overview: "This is overview", translated_name:)
    if has_episodes
      @episode1 = FactoryBot.create(
        :episode,
        number: 1,
        season: @season,
        original_air_date: Date.new(2023, 1, 1),
        runtime: 30,
        translated_name: "Pilot",
        backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/1280x720.png", "image/png")]
      )
      @episode2 = FactoryBot.create(
        :episode,
        number: 2,
        season: @season,
        original_air_date: Date.new(2023, 1, 2),
        runtime: 30,
        translated_name: "Ringtoneers",
        backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/1280x720.png", "image/png")]
      )
      @episode_watch_statuses = {@episode1 => :not_consumed, @episode2 => :consumed}
    end
    @episode_watch_statuses ||= {}
    FactoryBot.create(:cast_member, record: @season, person: FactoryBot.build(:person, translated_name: "John Doe"), character: "Bob")
    gallery_presenter = Galleries::Presenter.new(@season)
    assign(:show, @show)
    assign(:season, @season)
    assign(:gallery_presenter, gallery_presenter)
    assign(:cast_members, CastMembers::Season.new(@season).cast_members)
    assign(:pagination, Pagination::Seasons.new(@season, @show))
    assign(:watch_status, watch_status)
    assign(:episode_watch_statuses, @episode_watch_statuses)
    assign(:stacks_with_previews, stacks_with_previews)
    assign(:stacks_next_page, stacks_next_page)
  end

  it "renders attributes" do
    render
    expect(rendered).to match(/Translated Title/)
    expect(rendered).to match(/Season 1/)
    expect(rendered.scan(" - Season 1").count).to eq 2 # An extra one for mobile layout
    expect(rendered).to match(/The OG season/)
    expect(rendered).to match(/This is overview/)
    expect(rendered).to match(/January 01, 2023/)
    expect(rendered).to match(/1h 0m/)
  end

  it "renders the cast members" do
    render
    assert_select "p", text: "John Doe"
    assert_select "small", text: "Bob"
    assert_select "a[href='#{cast_show_season_path(@season, show_id: @show)}']"
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
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_path(@show, @season)}']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_path(@show, @season)}'][disabled]", count: 0
  end

  it "renders the add to stack button when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    episode = FactoryBot.create(:episode, season: @season, number: 3)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_season_path(@show, @season)}']"
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_season_episode_path(@show, @season, episode)}']"
  end

  it "does not render the add to stack button when not authenticated" do
    allow(view).to receive(:authenticated?).and_return(false)
    episode = FactoryBot.create(:episode, season: @season, number: 3)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_season_path(@show, @season)}']", count: 0
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_season_episode_path(@show, @season, episode)}']", count: 0
  end

  it "renders the add to history buttons for each episode with the correct status when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    render
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_episode_path(@show, @season, @episode1)}'][data-status='not_consumed']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_episode_path(@show, @season, @episode2)}'][data-status='consumed']"
  end

  context "when the season is consumed" do
    let(:watch_status) { :consumed }

    it "renders the add to history button in a disabled state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_path(@show, @season)}'][data-status='consumed']"
    end
  end

  context "when the season is not consumed" do
    let(:watch_status) { :not_consumed }

    it "renders the add to history button" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_path(@show, @season)}'][data-status='not_consumed']"
    end
  end

  context "when season has no release date" do
    let(:has_episodes) { false }

    it "renders the add to history button in a disabled state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_path(@show, @season)}'][disabled]", count: 1
    end
  end

  context "when name matches the potential name" do
    let(:translated_name) { "Season 1" }

    it "does not render the subtitle with the name" do
      render
      expect(rendered.scan(" - Season 1").count).to eq 2 # 1 for mobile layout. It is not rendering it 3 names
    end
  end

  context "when name does not match the potential name" do
    let(:translated_name) { "Season 01" }

    it "renders the subtitle with the name" do
      render
      assert_select "p.italic", text: "Season 01", count: 2 # An extra one for mobile layout
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
    assert_select "a.font-domine", text: "Episode 1 - Pilot"
    assert_select "a.font-domine", text: "Episode 2 - Ringtoneers"
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

    it "renders the next season link" do
      render
      assert_select "a[href='#{show_season_path(2, show_id: @show)}']", text: "Next", count: 2
    end
  end

  context "when there is no next season" do
    it "does not render next season link" do
      render
      assert_select "a", text: "Next", count: 0
    end
  end

  context "when the season has some stacks" do
    let(:stack) { FactoryBot.create(:stack, name: "Amazing Stack") }
    let(:stack_items) { [FactoryBot.create(:stack_item, item: @season)] }
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
          assert_select "a[href='#{load_more_top_stacks_show_season_path(@season, show_id: @show, page: 2)}']"
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
