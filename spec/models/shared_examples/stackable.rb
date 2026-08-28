RSpec.shared_examples_for "a stackable model" do
  describe "associations" do
    it { should have_many(:stack_items).dependent(:destroy) }
    it { should have_many(:stacks).through(:stack_items) }
  end

  describe "#user_stacks" do
    context "with no user" do
      let(:user) { nil }

      it "returns an empty array" do
        expect(item.user_stacks(user)).to eq([])
      end
    end

    context "with a user" do
      let(:user) { FactoryBot.create(:user) }

      it "only returns stacks that the item is a part of for that user" do
        # A stack for that user that has the item
        has_item = FactoryBot.create(:stack, user: user)
        FactoryBot.create(:stack_item, stack: has_item, item:)
        # A stack for that user that does not have the item
        FactoryBot.create(:stack, user: user)
        # A stack for another user that has the item
        no_item = FactoryBot.create(:stack)
        FactoryBot.create(:stack_item, stack: no_item, item:)
        # A stack for another user that does not have the item
        FactoryBot.create(:stack)
        expect(item.user_stacks(user)).to eq([has_item.id])
      end
    end
  end

  describe "#stacks_with_previews" do
    before do
      # A stack for this item that is not part of results as outside of 3 per page limit
      stack1 = FactoryBot.create(:stack)
      FactoryBot.create(:stack_item, item:, stack: stack1)
      # A stack for this item
      @stack2 = FactoryBot.create(:stack)
      FactoryBot.create(:stack_item, item:, stack: @stack2)
      # A stack for this item with more than three stack items
      @stack3 = FactoryBot.create(:stack)
      FactoryBot.create(:stack_item, item:, stack: @stack3)
      FactoryBot.create(:stack_item, stack: @stack3)
      FactoryBot.create(:stack_item, stack: @stack3)
      FactoryBot.create(:stack_item, stack: @stack3)
      # A stack for this item
      @stack4 = FactoryBot.create(:stack)
      FactoryBot.create(:stack_item, item:, stack: @stack4)
      # A stack that this item is not a part of
      FactoryBot.create(:stack)
    end

    it "returns a hash with only three stacks as keys" do
      result = item.stacks_with_previews.first
      expect(result.keys).to contain_exactly(@stack2, @stack3, @stack4)
    end

    it "returns only three stack items per stack" do
      result = item.stacks_with_previews.first
      stack3_results = result[@stack3]
      expect(stack3_results.count).to eq 3
    end

    it "returns an empty hash when there are no stacks" do
      item.stacks.destroy_all
      result = item.stacks_with_previews.first
      expect(result).to eq({})
    end

    it "includes a boolean indicating a next page" do
      has_more = item.stacks_with_previews.last
      expect(has_more).to be_truthy
    end
  end
end
