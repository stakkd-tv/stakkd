require "rails_helper"

RSpec.describe "crew_members/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::CrewMembersPresenter.new(relatable.crew_members))
    def view.relatable_model = "movie"

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_crew_members_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_crew_members_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='crew_member']"
  end

  it "renders the new crew member form" do
    render
    assert_select "form[action='#{movie_crew_members_path(relatable)}']" do
      assert_select "input[name='crew_member[person_id]']"
      assert_select "input[name='crew_member[job_id]']"
    end
  end
end
