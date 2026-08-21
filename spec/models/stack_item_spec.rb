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
end
