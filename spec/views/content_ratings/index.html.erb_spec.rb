require "rails_helper"

RSpec.describe "content_ratings/index", type: :view do
  let(:show) { FactoryBot.create(:show) }

  before(:each) do
    assign(:show, show)
    assign(:table_presenter, Tabulator::ContentRatingsPresenter.new(show.content_ratings))
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{show_content_ratings_path(show)}']"
    assert_select "div[data-table-editor-model-name-value='content_rating']"
    assert_select "div[data-table-editor-group-by-value='country_id']"
  end

  it "renders the new content rating form" do
    render
    assert_select "form[action='#{show_content_ratings_path(show)}']" do
      assert_select "select[name='content_rating[certification_id]']"
    end
  end
end
