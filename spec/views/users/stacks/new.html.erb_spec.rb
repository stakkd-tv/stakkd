require "rails_helper"

RSpec.describe "users/stacks/new.html.erb", type: :view do
  let(:user) { FactoryBot.create(:user, username: "lol") }
  let(:stack) { user.stacks.new }

  before(:each) do
    allow(view).to receive(:params).and_return({controller: "users/stacks", action: "new"})
    assign(:user, user)
    assign(:stack, stack)
  end

  it "renders nav links" do
    render
    assert_select "a[data-active='false']", text: "Profile"
    assert_select "a[data-active='false']", text: "History"
    assert_select "a[data-active='false']", text: "Progress"
    assert_select "a[data-active='false']", text: "Collection"
    assert_select "a[data-active='false']", text: "Ratings"
    assert_select "a[data-active='true']", text: "Stacks"
    assert_select "a[data-active='false']", text: "Comments"
    assert_select "a[data-active='false']", text: "Followers"
    assert_select "a[data-active='false']", text: "Following"
  end

  it "renders a link to cancel" do
    render
    assert_select "a[href='#{user_stacks_path(user)}']", text: "Cancel"
  end

  it "renders a form to create a new stack" do
    render
    assert_select "form[action='#{user_stacks_path(user)}']" do
      assert_select "input[type='text'][name='stack[name]']"
      assert_select "textarea[name='stack[description]']"
      assert_select "input[type='hidden'][name='stack[private]']"
    end
  end
end
