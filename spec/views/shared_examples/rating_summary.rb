RSpec.shared_examples "a media page rating summary" do |summary_count|
  context "when the item has community ratings" do
    let(:community_scores) { [7, 8, 10] }

    it "renders the rounded community score and vote count in each header" do
      render

      assert_select "[aria-label='Community rating']", count: summary_count do
        assert_select "span.font-fugaz", text: "8.3", count: summary_count
        assert_select "span", text: "Community · 3 ratings", count: summary_count
      end
    end
  end

  context "when the item has no ratings" do
    it "does not render a community summary" do
      render

      assert_select "[aria-label='Community rating']", count: 0
    end
  end
end
