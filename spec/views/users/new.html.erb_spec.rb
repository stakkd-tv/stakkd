require "rails_helper"

RSpec.describe "users/new", type: :view do
  before(:each) do
    @trivia = UsersController::TRIVIA.sample
    assign(:user, User.new)
    assign(:trivia, @trivia)
  end

  it "renders the new user form" do
    render

    assert_select "form[action='#{users_path}'][method='post']" do
      assert_select "input[name='user[username]']"
      assert_select "input[name='user[email_address]']"
      assert_select "input[name='user[password]']"
      assert_select "input[name='user[password_confirmation]']"
      assert_select "input[name='trivia_question_name'][value='#{@trivia[:name]}']"
      assert_select "input[name='trivia_answer']"
    end
  end
end
