require "rails_helper"

RSpec.describe "episodes/new", type: :view do
  let(:episode) { Episode.new }
  let(:season) { show.seasons.first }
  let(:show) { FactoryBot.create(:show) }

  before(:each) do
    assign(:show, show)
    assign(:season, season)
    assign(:episode, episode)
  end

  it "renders the episodes form" do
    render

    assert_select "form[action='#{show_season_episodes_path(show, season)}'][method='post']" do
      assert_select "input[name='episode[number]']"
      assert_select "input[name='episode[translated_name]']"
      assert_select "input[name='episode[original_name]']"
      assert_select "input[name='episode[original_air_date]']"
      assert_select "textarea[name='episode[overview]']"
      assert_select "input[name='episode[runtime]']"
      assert_select "select[name='episode[episode_type]']"
      assert_select "input[name='episode[imdb_id]']"
      assert_select "input[name='episode[production_code]']"
    end
  end
end
