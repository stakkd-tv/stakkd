require "rails_helper"

RSpec.describe "users/show", type: :view do
  before(:each) do
    @user = FactoryBot.create(
      :user,
      username: "lol",
      profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/support/assets/400x400.png"), "image/png"),
      background: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/support/assets/300x450.png"), "image/png")
    )
    assign(:user, @user)
  end

  it "renders attributes" do
    render
    assert_select "h1", text: "lol"
    assert_select "img[src*='400x400.png']"
    assert_select "img[src*='300x450.png']"
    assert_select "p", text: "Member since #{@user.created_at.strftime("%d %B %Y")}"
  end

  it "renders nav links" do
    render
    assert_select "a[data-active='true']", text: "Profile"
    assert_select "a", text: "History"
    assert_select "a", text: "Profile"
    assert_select "a", text: "Progress"
    assert_select "a", text: "Collection"
    assert_select "a", text: "Ratings"
    assert_select "a", text: "Stacks"
    assert_select "a", text: "Comments"
    assert_select "a", text: "Followers"
    assert_select "a", text: "Following"
  end

  it "renders the biography as markdown" do
    @user.update(biography: "Some bio")
    render
    assert_select "div[data-controller='markdown-renderer'][data-markdown-renderer-markdown-value='Some bio']"
  end

  it "does not render bio when none specified" do
    render
    assert_select "div[data-controller='markdown-renderer']", count: 0
  end
end
