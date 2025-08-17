require "rails_helper"

RSpec.describe "releases/editor", type: :view do
  let(:movie) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:movie, movie)
    assign(:table_presenter, Tabulator::ReleasesPresenter.new(movie.releases))
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_releases_path(movie)}']"
    assert_select "div[data-table-editor-model-name-value='release']"
    assert_select "div[data-table-editor-group-by-value='country_id']"
  end

  it "renders the new alternative name form" do
    render
    assert_select "form[action='#{movie_releases_path(movie)}']" do
      assert_select "input[name='release[date]']"
      assert_select "select[name='release[type]']"
      assert_select "select[name='release[certification_id]']"
      assert_select "input[name='release[note]']"
    end
  end
end
