require "rails_helper"

RSpec.describe "guest_stars/index", type: :view do
  let(:episode) { FactoryBot.create(:episode) }

  before(:each) do
    assign(:episode, episode)
    assign(:season, episode.season)
    assign(:show, episode.show)
    assign(:table_presenter, Tabulator::CastMembersPresenter.new(episode.guest_stars))
  end

  it "renders the table editor" do
    render
    assert_select "div[data-controller='table-editor']"
    assert_select "div[data-table-editor-path-prefix-value='#{show_season_episode_guest_stars_path(episode_id: episode, season_id: episode.season, show_id: episode.show)}']"
    assert_select "div[data-table-editor-model-name-value='cast_member']"
  end

  it "renders the new cast member form" do
    render
    assert_select "form[action='#{show_season_episode_guest_stars_path(episode_id: episode, season_id: episode.season, show_id: episode.show)}']" do
      assert_select "input[name='cast_member[person_id]']"
      assert_select "input[name='cast_member[character]']"
    end
  end
end
