require "rails_helper"

RSpec.describe "search/show", type: :view do
  before do
    allow(view).to receive(:params).and_return(
      ActionController::Parameters.new(q: "search text", id: "movies")
    )
    @results = [{slug: "test-slug", image: "1:1.png", aspect: "aspect-square", title: "Test Movie"}]
    assign(:results, @results)
    assign(:page, 1)
  end

  it "renders the results" do
    assign(:has_more, false)
    render
    assert_select "h3", text: "Test Movie"
    assert_select "img.aspect-square[src*='1:1']"
    assert_select "a[href='/movies/test-slug']"
  end

  context "when more results can be loaded" do
    it "replaces the existing load more frame with a new one" do
      assign(:has_more, true)
      render
      assert_select "turbo-stream[target='load_more_movies'][action='replace']" do
        assert_select "turbo-frame#load_more_movies[loading='lazy'][src='#{search_path(id: "movies", q: "search text", page: 2, format: :turbo_stream)}']"
      end
    end
  end

  context "when no more results can be loaded" do
    it "removes the load more frame from the DOM" do
      assign(:has_more, false)
      render
      assert_select "turbo-stream[target='load_more_movies'][action='remove']"
    end
  end
end
