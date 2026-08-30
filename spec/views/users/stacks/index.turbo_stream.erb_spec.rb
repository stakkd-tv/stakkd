require "rails_helper"

RSpec.describe "users/stacks/index.turbo_stream.erb", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:stack) { FactoryBot.create(:stack, name: "Crazy Stack", user:) }
  let(:stack_item) { FactoryBot.create(:stack_item, stack:) }
  let(:stacks_with_previews) { {stack => [stack_item]} }
  let(:stacks_next_page) { nil }

  before do
    def view.current_user = nil
    assign(:user, user)
    assign(:stacks_with_previews, stacks_with_previews)
    assign(:stacks_next_page, stacks_next_page)
  end

  it "renders previews for each stack inside a turbo stream" do
    render
    assert_select "turbo-stream[action='append'][target='top_stacks']" do
      assert_select "h6", text: "Crazy Stack"
    end
  end

  context "when there is no next page" do
    let(:stacks_next_page) { nil }

    it "renders a turbo stream to remove load more top stacks button" do
      render
      assert_select "turbo-stream[action='remove'][target='load_more_top_stacks']"
    end
  end

  context "when there is a next page" do
    let(:stacks_next_page) { 2 }

    it "updates the load more top stacks button with the next page" do
      render
      assert_select "turbo-stream[action='replace'][target='load_more_top_stacks']" do
        assert_select "turbo-frame[id='load_more_top_stacks']" do
          assert_select "a[href='#{user_stacks_path(user, page: 2)}']"
        end
      end
    end
  end
end
