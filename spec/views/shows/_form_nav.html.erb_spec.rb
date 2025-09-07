require "rails_helper"

RSpec.describe "shows/_form_nav", type: :view do
  context "when show is persisted" do
    it "renders the nav" do
      def view.action_name = "edit"
      show = FactoryBot.create(:show)
      render "shows/form_nav", show: show
      assert_select "a[href='#{edit_show_path(show)}'][data-active='true']"
      assert_select "a[href='#{posters_show_path(show)}'][data-active='false']"
      assert_select "a[href='#{backgrounds_show_path(show)}'][data-active='false']"
      assert_select "a[href='#{logos_show_path(show)}'][data-active='false']"
      assert_select "a[href='#{show_alternative_names_path(show)}'][data-active='false']"
      assert_select "a[href='#{show_genre_assignments_path(show)}'][data-active='false']"
      assert_select "a[href='#{show_keywords_path(show)}'][data-active='false']"
    end
  end

  context "when show is not persisted" do
    it "does not render the nav" do
      show = FactoryBot.build(:show)
      render "shows/form_nav", show: show
      expect(rendered).to eq ""
    end
  end
end
