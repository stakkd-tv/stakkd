require "rails_helper"

RSpec.describe "videos/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::VideosPresenter.new(relatable.videos))
    def view.relatable_model = "movie"

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_videos_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_videos_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='video']"
    assert_select "div[data-table-editor-group-by-value='type']"
  end

  it "renders the new video form" do
    render
    assert_select "form[action='#{movie_videos_path(relatable)}']" do
      assert_select "select[name='video[source]']"
      assert_select "input[name='video[source_key]']"
      assert_select "select[name='video[type]']"
    end
  end
end
