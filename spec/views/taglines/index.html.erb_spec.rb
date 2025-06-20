require "rails_helper"

RSpec.describe "taglines/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::TaglinesPresenter.new(relatable.taglines))
    def view.relatable_model = "movie"

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_taglines_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_taglines_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='tagline']"
  end

  it "renders the new tagline form" do
    render
    assert_select "form[action='#{movie_taglines_path(relatable)}']" do
      assert_select "input[name='tagline[tagline]']"
    end
  end
end
