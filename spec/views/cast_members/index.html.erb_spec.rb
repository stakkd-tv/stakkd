require "rails_helper"

RSpec.describe "cast_members/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::CastMembersPresenter.new(relatable.cast_members))
    def view.relatable_model = "movie"

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_cast_members_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_cast_members_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='cast_member']"
  end

  it "renders the new cast member form" do
    render
    assert_select "form[action='#{movie_cast_members_path(relatable)}']" do
      assert_select "input[name='cast_member[person_id]']"
      assert_select "input[name='cast_member[character]']"
    end
  end
end
