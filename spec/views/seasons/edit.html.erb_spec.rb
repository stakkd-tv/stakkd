require "rails_helper"

RSpec.describe "seasons/edit", type: :view do
  let(:season) { FactoryBot.create(:season) }

  before(:each) do
    assign(:season, season)
    assign(:show, season.show)
  end

  it "renders the edit show form" do
    render

    assert_select "form[action='#{show_season_path(season, show_id: season.show)}'][method='post']" do
      assert_select "input[name='season[number]']"
      assert_select "input[name='season[translated_name]']"
      assert_select "input[name='season[original_name]']"
      assert_select "textarea[name='season[overview]']"
    end
  end
end
