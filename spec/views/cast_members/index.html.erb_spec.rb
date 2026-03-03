require "rails_helper"

RSpec.describe "cast_members/index", type: :view do
  let(:relatable) { FactoryBot.create(:movie) }

  before(:each) do
    assign(:relatable, relatable)
    assign(:table_presenter, Tabulator::CastMembersPresenter.new(relatable.cast_members))

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

  it "does not render sections that are not needed" do
    render
    expect(rendered).not_to include("A note on recurring season regulars:")
    expect(rendered).not_to include("These are cast members that appear in every season. If a cast member does not appear in all seasons of this show, add them to each individual season instead.")
  end

  context "when relatable is a show" do
    let(:relatable) { FactoryBot.create(:show) }

    before do
      def view.relatable_model_plural = "shows"
    end

    it "renders a note about recurring regulars" do
      render
      expect(rendered).to include("A note on recurring season regulars:")
      expect(rendered).to include("These are cast members that appear in every season. If a cast member does not appear in all seasons of this show, add them to each individual season instead.")
    end
  end
end
