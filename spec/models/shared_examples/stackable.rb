RSpec.shared_examples_for "a stackable model" do
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
end
