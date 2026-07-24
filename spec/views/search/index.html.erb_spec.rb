require "rails_helper"

RSpec.describe "search/index", type: :view do
  before(:each) do
    allow(view).to receive(:params).and_return(
      ActionController::Parameters.new(q: "search text")
    )
    @tabs_with_results = [
      {tab: "movies", count: 2, initial_results: [{slug: "test-slug", image: "2:3.png", title: "Test Movie"}]},
      {tab: "shows", count: 1, initial_results: [{slug: "test-slug-show", image: "2:3.png", title: "Test Show"}]}
    ]
    stub_const("ApplicationController::GLOBAL_PER_PAGE", 1)
    assign(:tabs_with_results, @tabs_with_results)
    render
  end

  it "renders the search results controller" do
    assert_select "div[data-controller='search-results']"
  end

  it "renders the query" do
    assert_select "h2", text: "Search - search text"
  end

  it "renders the tabs in the side bar, with the first one being active" do
    assert_select "div.flex-col" do
      assert_select "button[data-sidetab-active='true'][data-tab='movies'][data-action='click->search-results#updateTab']", text: "Movies (2)"
      assert_select "button[data-sidetab-active='false'][data-tab='shows'][data-action='click->search-results#updateTab']", text: "Shows (1)"
    end
  end

  it "renders containers with results for each tab, with the first one being the only one visible" do
    assert_select "div.hidden[id='movies-results-container']", count: 0
    assert_select "div[id='movies-results-container']" do
      assert_select "h3", text: "Test Movie"
      assert_select "img.aspect-2\\/3[src*='2:3']"
      assert_select "a[href='/movies/test-slug']"
      # renders a load more frame
      assert_select "turbo-frame#load_more_movies[src='#{search_path(id: "movies", q: "search text", page: 2, format: :turbo_stream)}']"
    end

    assert_select "div.hidden[id='shows-results-container']" do
      assert_select "h3", text: "Test Show"
      assert_select "img.aspect-2\\/3[src*='2:3']"
      assert_select "a[href='/shows/test-slug-show']"
      # does not render a load more frame
      assert_select "turbo-frame#load_more_shows", count: 0
    end
  end
end
