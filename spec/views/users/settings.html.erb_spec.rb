require "rails_helper"

RSpec.describe "users/settings", type: :view do
  before(:each) do
    @user = FactoryBot.create(:user)
    assign(:user, @user)
  end

  it "renders the user settings form" do
    render

    assert_select "form[action='#{user_path(@user)}'][method='post']" do
      assert_select "input[name='user[profile_picture]']"
      assert_select "input[name='user[background]']"
      assert_select "textarea[name='user[biography]']"
      assert_select "input[name='user[private]']"
    end
  end
end
