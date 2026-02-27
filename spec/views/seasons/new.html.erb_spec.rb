require "rails_helper"

RSpec.describe "seasons/edit", type: :view do
  let(:season) { Season.new }
  let(:show) { FactoryBot.create(:show) }

  before(:each) do
    assign(:show, show)
    assign(:season, season)
  end

  it "renders the edit season form" do
    render

    assert_select "form[action='#{show_seasons_path(show)}'][method='post']" do
      assert_select "input[name='season[number]']"
      assert_select "input[name='season[translated_name]']"
      assert_select "input[name='season[original_name]']"
      assert_select "textarea[name='season[overview]']"
    end
  end
end
