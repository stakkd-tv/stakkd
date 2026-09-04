require "rails_helper"

RSpec.describe "users/show", type: :view do
  let(:private) { false }
  let(:recently_watched) { [] }
  let(:stacks) { [] }
  let(:user) do
    FactoryBot.create(
      :user,
      username: "lol",
      profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/support/assets/400x400.png"), "image/png"),
      background: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec/support/assets/300x450.png"), "image/png"),
      private:
    )
  end

  before(:each) do
    allow(view).to receive(:params).and_return({controller: "users", action: "show"})
    assign(:user, user)
    assign(:recently_watched, recently_watched)
    assign(:stacks, stacks)
  end

  shared_examples_for "a public profile" do
    it "renders attributes" do
      render
      assert_select "h1", text: "lol"
      assert_select "img[src*='400x400.png']"
      assert_select "img[src*='300x450.png']"
      assert_select "p", text: "Member since #{user.created_at.strftime("%d %B %Y")}"
    end

    it "renders nav links" do
      render
      assert_select "a[data-active='true']", text: "Profile"
      assert_select "a[data-active='false']", text: "History"
      assert_select "a[data-active='false']", text: "Progress"
      assert_select "a[data-active='false']", text: "Collection"
      assert_select "a[data-active='false']", text: "Ratings"
      assert_select "a[data-active='false']", text: "Stacks"
      assert_select "a[data-active='false']", text: "Comments"
      assert_select "a[data-active='false']", text: "Followers"
      assert_select "a[data-active='false']", text: "Following"
    end

    it "renders the biography as markdown" do
      user.update(biography: "Some bio")
      render
      assert_select "div[data-controller='markdown-renderer'][data-markdown-renderer-markdown-value='Some bio']"
    end

    it "does not render bio when none specified" do
      render
      assert_select "div[data-controller='markdown-renderer']", count: 0
    end

    it "renders the deletion dialog" do
      render
      assert_select "dialog[data-controller='deletion-dialog']"
    end

    context "when the user does not have any history items" do
      it "does not render the recently watched section" do
        render
        assert_select "h4.text-xl", text: "Recently watched:", count: 0
      end
    end

    context "when the user has history items" do
      let(:item) { FactoryBot.create(:movie, translated_title: "Test Movie") }
      let(:history_item) { FactoryBot.create(:history_item, user: user, item:) }
      let(:recently_watched) { [HistoryItemPresenter.new(history_item)] }

      it "renders the recently watched section" do
        render
        assert_select "h4.text-xl", text: "Recently watched:"
        assert_select "p.font-domine", text: "Test Movie"
        assert_select "p.text-xs", text: "Movie"
      end
    end

    context "when the user does not have any stacks" do
      it "does not render the stacks section" do
        render
        assert_select "h4.text-xl", text: "Stacks:", count: 0
      end
    end

    context "when the user has stacks" do
      let(:stack) { FactoryBot.create(:stack, user: user, name: "Test Stack") }
      let(:stacks) { {stack => []} }

      it "renders the stacks section" do
        render
        assert_select "h4.text-xl", text: "Stacks:"
        assert_select "h6.font-domine", text: "Test Stack"
      end
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
      user.update(biography: "Some bio")
      render
      assert_select "div[data-controller='markdown-renderer'][data-markdown-renderer-markdown-value='Some bio']", count: 0
    end
  end

  context "when the user is the current logged in private user" do
    let(:private) { true }

    before do
      @user = user
      def view.current_user
        @user
      end
    end

    it_behaves_like "a public profile"
  end
end
