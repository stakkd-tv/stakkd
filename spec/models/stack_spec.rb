require "rails_helper"
require_relative "shared_examples/slugify"

RSpec.describe Stack, type: :model do
  describe "associations" do
    it { should belong_to(:user).optional }
    it { should have_many(:stack_items).dependent(:delete_all) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:type).in_array(Stack::TYPES) }
    it { should validate_inclusion_of(:sorting_method).in_array(Stack::SORTING_METHODS) }
    it { should validate_length_of(:description).is_at_most(100) }
  end

  describe ".official" do
    it "returns only official stacks" do
      official_stack = FactoryBot.create(:stack, :official)
      FactoryBot.create(:stack)
      expect(Stack.official).to eq([official_stack])
    end
  end

  it_behaves_like "a slugified model", :stack, :name

  describe ".inheritance_column" do
    it "returns nil" do
      expect(Stack.inheritance_column).to be_nil
    end
  end

  describe "add!" do
    let(:stack) { FactoryBot.create(:stack) }
    let(:item) { FactoryBot.create(:movie) }

    subject { stack.add!(item, added_at: DateTime.new(2026, 1, 1, 10)) }

    context "when the item is not in the stack" do
      it "adds the item to the stack" do
        subject
        expect(stack.stack_items.count).to eq 1
        stack_item = stack.stack_items.first
        expect(stack_item.item).to eq item
        expect(stack_item.added_at).to eq DateTime.new(2026, 1, 1, 10)
      end
    end

    context "when the item is already in the stack" do
      it "raises an error" do
        StackItem.create!(stack:, item:, added_at: Time.current)
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#remove!" do
    let(:stack) { FactoryBot.create(:stack) }
    let(:item) { FactoryBot.create(:movie) }

    subject { stack.remove!(item) }

    context "when the item is in the stack" do
      it "removes the item from the stack" do
        StackItem.create!(stack:, item:, added_at: Time.current)
        expect(stack.stack_items.count).to eq 1
        subject
        expect(stack.stack_items.count).to eq 0
      end
    end

    context "when the item is not in the stack" do
      it "raises an error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#slug=" do
    it "sets the name" do
      stack = Stack.new
      stack.slug = "test"
      expect(stack.name_kebab).to eq "test"
    end
  end

  describe "#to_s" do
    it "returns the name" do
      stack = Stack.new(name: "Test Stack")
      expect(stack.to_s).to eq "Test Stack"
    end
  end
end
