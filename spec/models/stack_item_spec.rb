require "rails_helper"

RSpec.describe StackItem, type: :model do
  describe "associations" do
    it { should belong_to(:stack) }
    it { should belong_to(:item) }
  end

  describe "validations" do
    subject { FactoryBot.build(:stack_item) }
    it { should validate_presence_of(:added_at) }
    it { should validate_presence_of(:position) }
    it { should validate_uniqueness_of(:stack_id).scoped_to([:item_type, :item_id]) }
  end

  describe ".first_three_per_stack" do
    it "only returns the first 3 stack items per stack ordered by added at" do
      stack = FactoryBot.create(:stack)
      FactoryBot.create(:stack_item, stack: stack, added_at: Time.current)
      stack_item2 = FactoryBot.create(:stack_item, stack: stack, added_at: Time.current - 1.second)
      stack_item3 = FactoryBot.create(:stack_item, stack: stack, added_at: Time.current - 3.seconds)
      stack_item4 = FactoryBot.create(:stack_item, stack: stack, added_at: Time.current - 2.seconds)
      result = StackItem.first_three_per_stack
      expect(result.size).to eq 3
      expect(result.first).to eq stack_item3
      expect(result.second).to eq stack_item4
      expect(result.last).to eq stack_item2
    end

    it "scopes stack_item_rank to the stack" do
      stack1 = FactoryBot.create(:stack)
      stack_item1 = FactoryBot.create(:stack_item, stack: stack1)
      stack2 = FactoryBot.create(:stack)
      stack_item2 = FactoryBot.create(:stack_item, stack: stack2)
      result = StackItem.first_three_per_stack
      expect(result.size).to eq 2
      stack_item1_result = result.find { |item| item.id == stack_item1.id }
      expect(stack_item1_result.stack_item_rank).to eq 1
      stack_item2_result = result.find { |item| item.id == stack_item2.id }
      expect(stack_item2_result.stack_item_rank).to eq 1
    end
  end
end
