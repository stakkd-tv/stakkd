require "rails_helper"

RSpec.describe "keywords/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::KeywordTaggingsPresenter.new(relatable.keyword_taggings))
    assign(:tags, [])
    def view.relatable_model = "movie"

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_keywords_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_keywords_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='tagging']"
  end

  it "renders the new keyword form" do
    render
    assert_select "form[action='#{movie_keywords_path(relatable)}']" do
      assert_select "select[name='tag']"
    end
  end
end
