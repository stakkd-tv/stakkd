require "rails_helper"

RSpec.describe "alternative_names/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::AlternativeNamesPresenter.new(relatable.alternative_names))

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_alternative_names_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_alternative_names_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='alternative_name']"
  end

  it "renders the new alternative name form" do
    render
    assert_select "form[action='#{movie_alternative_names_path(relatable)}']" do
      assert_select "input[name='alternative_name[name]']"
      assert_select "input[name='alternative_name[type]']"
      assert_select "select[name='alternative_name[country_id]']"
    end
  end
end
