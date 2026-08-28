require "rails_helper"

RSpec.describe "episodes/show", type: :view do
  let(:posters) { [] }
  let(:backgrounds) { [] }
  let(:original_air_date) { Date.new(2023, 1, 1) }
  let(:imdb_id) { nil }
  let(:watch_status) { :not_consumed }
  let(:stacks_with_previews) { {} }
  let(:stacks_next_page) { nil }

  before(:each) do
    def view.authenticated? = false
    def view.current_user = nil
    @season = FactoryBot.create(:season, number: 1, posters:, overview: "This is overview", translated_name: "NAME")
    @show = @season.show
    @show.ordered_seasons.first.destroy # Destroy specials season, not needed for this test
    @episode = FactoryBot.create(
      :episode,
      number: 2,
      season: @season,
      original_air_date:,
      runtime: 30,
      translated_name: "Pilot",
      backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/1280x720.png", "image/png")],
      imdb_id:
    )
    FactoryBot.create(:cast_member, record: @episode, person: FactoryBot.build(:person, translated_name: "John Doe"), character: "Bob")
    gallery_presenter = Galleries::Presenter.new(@season)
    assign(:show, @show)
    assign(:season, @season)
    assign(:gallery_presenter, gallery_presenter)
    assign(:cast_members, CastMembers::Episode.new(@episode).cast_members)
    assign(:pagination, Pagination::Episodes.new(@episode, @season, @show))
    assign(:watch_status, watch_status)
    assign(:stacks_with_previews, stacks_with_previews)
    assign(:stacks_next_page, stacks_next_page)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Episode 2/)
    expect(rendered).to match(/Pilot/)
    expect(rendered).to match(/January 01, 2023/)
    expect(rendered).not_to match(/TBA/i)
    assert_select "a", text: "NAME"
    assert_select "a", text: @show.translated_title
  end

  it "renders the cast members" do
    render
    assert_select "p", text: "John Doe"
    assert_select "small", text: "Bob"
    assert_select "a[href='#{cast_show_season_episode_path(@episode, season_id: @season, show_id: @show)}']"
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
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_episode_path(@show, @season, @episode)}']"
    assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_episode_path(@show, @season, @episode)}'][disabled]", count: 0
  end

  it "renders the add to stack button when authenticated" do
    allow(view).to receive(:authenticated?).and_return(true)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_season_episode_path(@show, @season, @episode)}']"
  end

  it "does not render the add to stack button when not authenticated" do
    allow(view).to receive(:authenticated?).and_return(false)
    render
    assert_select "button[title='Add to stack'][data-stack-button-add-to-stack-url-value='#{add_to_stack_show_season_episode_path(@show, @season, @episode)}']", count: 0
  end

  context "when the episode is consumed" do
    let(:watch_status) { :consumed }

    it "renders the button in a consumed state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-status='consumed']"
    end
  end

  context "when the episode is not consumed" do
    let(:watch_status) { :not_consumed }

    it "renders the button in an unconsumed state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-status='not_consumed']"
    end
  end

  context "when episode has no air date" do
    let(:original_air_date) { nil }

    it "renders TBA" do
      render
      expect(rendered).to match(/TBA/)
    end

    it "renders the add to history button in a disabled state" do
      allow(view).to receive(:authenticated?).and_return(true)
      render
      assert_select "button[title='Add to history'][data-history-button-add-to-history-url-value='#{add_to_history_show_season_episode_path(@show, @season, @episode)}'][disabled]", count: 1
    end
  end

  context "when the episode has directors" do
    before do
      job = FactoryBot.create(:job, name: Job::DIRECTOR)
      @person = FactoryBot.create(:person, translated_name: "John Doe")
      FactoryBot.create(:crew_member, job:, person: @person, record: @episode)
      @person2 = FactoryBot.create(:person, translated_name: "Chris Doe")
      FactoryBot.create(:crew_member, job:, person: @person2, record: @episode)
    end

    it "renders the directors" do
      render
      expect(rendered).to match(/Directed by:/)
      assert_select "a", text: "John Doe"
      assert_select "a", text: "Chris Doe"
    end
  end

  context "when the episode has no directors" do
    it "does not render the directors" do
      render
      expect(rendered).not_to match(/Directed by:/)
    end
  end

  context "when the episode has writers" do
    before do
      job = FactoryBot.create(:job, name: Job::WRITER)
      @person = FactoryBot.create(:person, translated_name: "John Doe")
      FactoryBot.create(:crew_member, job:, person: @person, record: @episode)
      @person2 = FactoryBot.create(:person, translated_name: "Chris Doe")
      FactoryBot.create(:crew_member, job:, person: @person2, record: @episode)
    end

    it "renders the writers" do
      render
      expect(rendered).to match(/Written by:/)
      assert_select "a", text: "John Doe"
      assert_select "a", text: "Chris Doe"
    end
  end

  context "when the episode has no writers" do
    it "does not render the writers" do
      render
      expect(rendered).not_to match(/Written by:/)
    end
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

  context "when the episode has some stacks" do
    let(:stack) { FactoryBot.create(:stack, name: "Amazing Stack") }
    let(:stack_items) { [FactoryBot.create(:stack_item, item: @episode)] }
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
          assert_select "a[href='#{load_more_top_stacks_show_season_episode_path(@episode, show_id: @show, season_id: @season, page: 2)}']"
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
