require "rails_helper"

RSpec.describe "episodes/edit", type: :view do
  let(:episode) { FactoryBot.create(:episode, number: 1) }

  before(:each) do
    assign(:show, episode.show)
    assign(:season, episode.season)
    assign(:episode, episode)
  end

  it "renders the edit episodes form" do
    render

    assert_select "form[action='#{show_season_episode_path(episode, season_id: episode.season, show_id: episode.show)}'][method='post']" do
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
