require "rails_helper"

RSpec.describe Stack, type: :model do
  describe "associations" do
    it { should belong_to(:user).optional }
    it { should have_many(:stack_items).dependent(:delete_all) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:type).in_array(Stack::TYPES) }
    it { should validate_inclusion_of(:sorting_method).in_array(Stack::SORTING_METHODS) }
  end

  describe ".official" do
    it "returns only official stacks" do
      official_stack = FactoryBot.create(:stack, :official)
      FactoryBot.create(:stack)
      expect(Stack.official).to eq([official_stack])
    end
  end

  describe ".inheritance_column" do
    it "returns nil" do
      expect(Stack.inheritance_column).to be_nil
    end
  end
end
