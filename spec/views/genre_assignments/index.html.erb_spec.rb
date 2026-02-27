require "rails_helper"

RSpec.describe "genre_assignments/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::GenreAssignmentsPresenter.new(relatable.genre_assignments))

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_genre_assignments_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_genre_assignments_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='genre_assignment']"
  end

  it "renders the new genre assignment form" do
    render
    assert_select "form[action='#{movie_genre_assignments_path(relatable)}']" do
      assert_select "select[name='genre_assignment[genre_id]']"
    end
  end
end
