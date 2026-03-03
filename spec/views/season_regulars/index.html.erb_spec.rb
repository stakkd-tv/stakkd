require "rails_helper"

RSpec.describe "season_regulars/index", type: :view do
  let(:season) { FactoryBot.create(:season) }

  before(:each) do
    assign(:season, season)
    assign(:show, season.show)
    assign(:table_presenter, Tabulator::CastMembersPresenter.new(season.season_regulars))
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{show_season_season_regulars_path(season_id: season, show_id: season.show)}']"
    assert_select "div[data-table-editor-model-name-value='cast_member']"
  end

  it "renders the new cast member form" do
    render
    assert_select "form[action='#{show_season_season_regulars_path(season_id: season, show_id: season.show)}']" do
      assert_select "input[name='cast_member[person_id]']"
      assert_select "input[name='cast_member[character]']"
    end
  end

  it "does not render the recurring regulars section" do
    render
    assert_select "h4", text: "Recurring season regulars", count: 0
  end

  context "when the show has a recurring season regular" do
    before do
      FactoryBot.create(:cast_member, record: season.show, person: FactoryBot.build(:person, translated_name: "Test name"), character: "Test character")
    end

    it "renders the recurring regulars section" do
      render
      assert_select "h4", text: "Recurring season regulars", count: 1
      assert_select "p", text: "Test name", count: 1
      assert_select "small", text: "Test character", count: 1
    end
  end
end
