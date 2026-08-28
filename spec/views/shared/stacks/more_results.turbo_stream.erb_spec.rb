require "rails_helper"

RSpec.describe "shared/stacks/more_results.turbo_stream.erb", type: :view do
  let(:stack) { FactoryBot.create(:stack, name: "Crazy Stack") }
  let(:stack_item) { FactoryBot.create(:stack_item, stack:) }
  let(:stacks_with_previews) { {stack => [stack_item]} }
  let(:stacks_next_page) { nil }
  let(:load_more_top_stacks_path) { "" }

  before do
    assign(:stacks_with_previews, stacks_with_previews)
    assign(:stacks_next_page, stacks_next_page)
    assign(:load_more_top_stacks_path, load_more_top_stacks_path)
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
    let(:load_more_top_stacks_path) { "/load-more?page=2" }

    it "updates the load more top stacks button with the next page" do
      render
      assert_select "turbo-stream[action='replace'][target='load_more_top_stacks']" do
        assert_select "turbo-frame[id='load_more_top_stacks']" do
          assert_select "a[href='/load-more?page=2']"
        end
      end
    end
  end
end
