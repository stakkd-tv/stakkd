require "rails_helper"

RSpec.describe "franchises/_form_nav", type: :view do
  context "when franchise is persisted" do
    it "renders the nav" do
      def view.action_name = "edit"
      franchise = FactoryBot.create(:franchise)
      render "franchises/form_nav", franchise: franchise
      assert_select "a[href='#{edit_franchise_path(franchise)}'][data-active='true']"
      assert_select "a[href='#{posters_franchise_path(franchise)}'][data-active='false']"
      assert_select "a[href='#{backgrounds_franchise_path(franchise)}'][data-active='false']"
      assert_select "a[href='#{logos_franchise_path(franchise)}'][data-active='false']"
      assert_select "a[href='#{editor_franchise_franchise_items_path(franchise)}'][data-active='false']"
    end
  end

  context "when franchise is not persisted" do
    it "does not render the nav" do
      franchise = FactoryBot.build(:franchise)
      render "franchises/form_nav", franchise: franchise
      expect(rendered).to eq ""
    end
  end
end
