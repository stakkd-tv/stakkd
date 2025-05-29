require "rails_helper"

RSpec.describe "people/_form_nav", type: :view do
  context "when person is persisted" do
    it "renders the nav" do
      def view.action_name = "edit"
      person = FactoryBot.create(:person)
      render "people/form_nav", person: person
      assert_select "a[href='#{edit_person_path(person)}'][data-active='true']"
      assert_select "a[href='#{images_person_path(person)}'][data-active='false']"
    end
  end

  context "when person is not persisted" do
    it "does not render the nav" do
      person = FactoryBot.build(:person)
      render "people/form_nav", person: person
      expect(rendered).to eq ""
    end
  end
end
