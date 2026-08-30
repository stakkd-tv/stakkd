require "rails_helper"

RSpec.describe "users/stacks/index.html.erb", type: :view do
  let(:logged_in_user) { nil }
  let(:stacks_with_previews) { {} }
  let(:stacks_next_page) { nil }
  let(:user) { FactoryBot.create(:user, username: "lol") }

  before(:each) do
    @logged_in_user = logged_in_user
    def view.current_user = @logged_in_user

    allow(view).to receive(:params).and_return({controller: "users/stacks", action: "index"})
    assign(:user, user)
    assign(:stacks_with_previews, stacks_with_previews)
    assign(:stacks_next_page, stacks_next_page)
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

  context "when the user is the logged in user" do
    let(:logged_in_user) { user }

    it "renders 'Your Stacks'" do
      render
      assert_select "h4", text: "Your Stacks"
    end
  end

  context "when the user is not the logged in user" do
    it "renders 'username's Stacks'" do
      render
      assert_select "h4", text: "#{user.username}'s Stacks"
    end
  end

  context "when the user has no stacks" do
    let(:stacks_with_previews) { {} }

    it "renders a note" do
      render
      assert_select "p", text: "No stacks yet. Learn more about stacks here."
    end
  end

  context "when the user has some stacks" do
    let(:stack) { FactoryBot.create(:stack, name: "Amazing Stack", user:) }
    let(:stacks_with_previews) { {stack => []} }

    it "renders the stacks" do
      render
      assert_select "turbo-frame[id='top_stacks']" do
        assert_select "h6", text: "Amazing Stack"
      end
    end

    context "when more stacks can be loaded" do
      let(:stacks_next_page) { 2 }

      it "renders the load more button" do
        render
        assert_select "turbo-frame[id='load_more_top_stacks']" do
          assert_select "a[href='#{user_stacks_path(user, page: 2)}']"
        end
      end
    end

    context "when no more stacks can be loaded" do
      it "does not render the load more button" do
        render
        assert_select "turbo-frame[id='load_more_top_stacks']", count: 0
      end
    end
  end
end
