require "rails_helper"

RSpec.describe "franchises/edit", type: :view do
  let(:franchise) { FactoryBot.create(:franchise) }

  before(:each) do
    assign(:franchise, franchise)
  end

  it "renders the edit franchise form" do
    render

    assert_select "form[action='#{franchise_path(franchise)}'][method='post']" do
      assert_select "input[name='franchise[original_title]']"
      assert_select "input[name='franchise[translated_title]']"
      assert_select "textarea[name='franchise[overview]']"
      assert_select "input[name='franchise[homepage]']"
    end
  end
end
