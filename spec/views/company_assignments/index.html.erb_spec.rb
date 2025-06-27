require "rails_helper"

RSpec.describe "company_assignments/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::CompanyAssignmentsPresenter.new(relatable.company_assignments))
    def view.relatable_model = "movie"

    def view.relatable_model_plural = "movies"

    def view.nested_path_for(relatable:) = movie_company_assignments_path(relatable)
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{movie_company_assignments_path(relatable)}']"
    assert_select "div[data-table-editor-model-name-value='company_assignment']"
  end

  it "renders the new company assignment form" do
    render
    assert_select "form[action='#{movie_company_assignments_path(relatable)}']" do
      assert_select "select[name='company_assignment[company_id]']"
    end
  end
end
