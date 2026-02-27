require "rails_helper"

RSpec.describe "seasons/_form_nav", type: :view do
  context "when season is persisted" do
    it "renders the nav" do
      def view.action_name = "edit"
      show = FactoryBot.create(:show)
      season = show.seasons.first
      render "seasons/form_nav", season: season
      assert_select "a[href='#{edit_show_season_path(season, show_id: show)}'][data-active='true']"
      assert_select "a[href='#{posters_show_season_path(season, show_id: show)}'][data-active='false']"
      # TODO: Other stuff
      # assert_select "a[href='#'][data-active='false']"
      # assert_select "a[href='#'][data-active='false']"
    end
  end

  context "when season is not persisted" do
    it "does not render the nav" do
      season = FactoryBot.build(:season)
      render "seasons/form_nav", season: season
      expect(rendered).to eq ""
    end
  end
end
