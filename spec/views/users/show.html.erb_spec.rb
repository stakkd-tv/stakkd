require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:private) { false }

  before(:each) do
    @user = FactoryBot.create(
      :user,
      username: "lol",
      profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/support/assets/400x400.png"), "image/png"),
      background: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/support/assets/300x450.png"), "image/png"),
      private:
    )
    assign(:user, @user)
  end

  shared_examples_for "a public profile" do
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

  context "when the user is public" do
    before do
      def view.current_user = nil
    end

    it_behaves_like "a public profile"
  end

  context "when user is private" do
    let(:private) { true }

    before do
      def view.current_user = nil
    end

    it "renders a notice with no nav links" do
      render
      assert_select "a", text: "Profile", count: 0
      assert_select "a", text: "History", count: 0
      assert_select "a", text: "Profile", count: 0
      assert_select "a", text: "Progress", count: 0
      assert_select "a", text: "Collection", count: 0
      assert_select "a", text: "Ratings", count: 0
      assert_select "a", text: "Stacks", count: 0
      assert_select "a", text: "Comments", count: 0
      assert_select "a", text: "Followers", count: 0
      assert_select "a", text: "Following", count: 0
      assert_select "h4", text: "This user's profile is private. You won't be able to see their activity unless they accept your follow request."
    end

    it "does not render the bio" do
      @user.update(biography: "Some bio")
      render
      assert_select "div[data-controller='markdown-renderer'][data-markdown-renderer-markdown-value='Some bio']", count: 0
    end
  end

  context "when the user is the current logged in private user" do
    let(:private) { true }

    before do
      def view.current_user
        @user
      end
    end

    it_behaves_like "a public profile"
  end
end
