require "rails_helper"

RSpec.describe "episodes/_form_nav", type: :view do
  context "when episode is persisted" do
    it "renders the nav" do
      def view.action_name = "edit"
      episode = FactoryBot.create(:episode)
      render "episodes/form_nav", episode: episode
      assert_select "a[href='#{edit_show_season_episode_path(episode, season_id: episode.season, show_id: episode.show)}'][data-active='true']"
      assert_select "a[href='#{backgrounds_show_season_episode_path(episode, season_id: episode.season, show_id: episode.show)}'][data-active='false']"
      # TODO: Add more
    end
  end

  context "when episode is not persisted" do
    it "does not render the nav" do
      episode = FactoryBot.build(:episode)
      render "episodes/form_nav", episode: episode
      expect(rendered).to eq ""
    end
  end
end
