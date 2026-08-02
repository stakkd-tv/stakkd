require "rails_helper"

RSpec.describe "franchises/new", type: :view do
  let(:franchise) { Franchise.new }

  before(:each) do
    assign(:franchise, franchise)
  end

  it "renders the new franchise form" do
    render

    assert_select "form[action='#{franchises_path}'][method='post']" do
      assert_select "input[name='franchise[original_title]']"
      assert_select "input[name='franchise[translated_title]']"
      assert_select "textarea[name='franchise[overview]']"
      assert_select "input[name='franchise[homepage]']"
    end
  end
end
