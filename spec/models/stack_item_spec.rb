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

  describe "SORT_MAP" do
    it "should include all the required attributes" do
      StackItem::SORT_MAP.each do |key, hash|
        expect { key.constantize.table_name }.to_not raise_error
        expect(hash).to include(:title)
        expect(hash).to include(:release_date)
      end
    end
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

  describe ".ordered_by_position" do
    before do
      stack = FactoryBot.create(:stack)
      @stack_item1 = FactoryBot.create(:stack_item, stack: stack, position: 2)
      @stack_item2 = FactoryBot.create(:stack_item, stack: stack, position: 1)
    end

    context "ascending" do
      it "orders by position ascending" do
        result = StackItem.ordered_by_position
        expect(result).to eq [@stack_item2, @stack_item1]
      end
    end

    context "descending" do
      it "orders by position descending" do
        result = StackItem.ordered_by_position(:desc)
        expect(result).to eq [@stack_item1, @stack_item2]
      end
    end
  end

  describe ".ordered_by_added_at" do
    before do
      stack = FactoryBot.create(:stack)
      @stack_item1 = FactoryBot.create(:stack_item, stack: stack, added_at: Time.current)
      @stack_item2 = FactoryBot.create(:stack_item, stack: stack, added_at: Time.current - 1.hour)
    end

    context "ascending" do
      it "orders by added_at ascending" do
        result = StackItem.ordered_by_added_at
        expect(result).to eq [@stack_item2, @stack_item1]
      end
    end

    context "descending" do
      it "orders by added_at descending" do
        result = StackItem.ordered_by_added_at(:desc)
        expect(result).to eq [@stack_item1, @stack_item2]
      end
    end
  end

  describe ".ordered_by_title" do
    before do
      stack = FactoryBot.create(:stack)
      movie = FactoryBot.create(:movie, translated_title: "B")
      @stack_item1 = FactoryBot.create(:stack_item, stack: stack, item: movie)
      show = FactoryBot.create(:show, translated_title: "A")
      @stack_item2 = FactoryBot.create(:stack_item, stack: stack, item: show)
      season = FactoryBot.create(:season, translated_name: "1", show: show)
      @stack_item3 = FactoryBot.create(:stack_item, stack: stack, item: season)
      episode = FactoryBot.create(:episode, translated_name: "2", season: season)
      @stack_item4 = FactoryBot.create(:stack_item, stack: stack, item: episode)
    end

    context "ascending" do
      it "orders by title ascending" do
        result = StackItem.ordered_by_title
        expect(result).to eq [@stack_item3, @stack_item4, @stack_item2, @stack_item1]
      end
    end

    context "descending" do
      it "orders by title descending" do
        result = StackItem.ordered_by_title(:desc)
        expect(result).to eq [@stack_item1, @stack_item2, @stack_item4, @stack_item3]
      end
    end
  end

  describe ".ordered_by_release_date" do
    before do
      stack = FactoryBot.create(:stack)
      movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2026, 9, 22))
      @stack_item1 = FactoryBot.create(:stack_item, stack: stack, item: movie)
      show = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.new(2026, 9, 21))
      @stack_item2 = FactoryBot.create(:stack_item, stack: stack, item: show)
      season = FactoryBot.create(:season, :with_premiere_date, date_for_premiere: Date.new(2026, 9, 19))
      @stack_item3 = FactoryBot.create(:stack_item, stack: stack, item: season)
      episode = FactoryBot.create(:episode, original_air_date: Date.new(2026, 9, 20))
      @stack_item4 = FactoryBot.create(:stack_item, stack: stack, item: episode)
    end

    context "ascending" do
      it "orders by release date ascending" do
        result = StackItem.ordered_by_release_date
        expect(result).to eq [@stack_item3, @stack_item4, @stack_item2, @stack_item1]
      end
    end

    context "descending" do
      it "orders by release date descending" do
        result = StackItem.ordered_by_release_date(:desc)
        expect(result).to eq [@stack_item1, @stack_item2, @stack_item4, @stack_item3]
      end
    end
  end

  describe ".ordered_by_runtime" do
    context "ascending" do
      it "orders by runtime ascending" do
        skip "TODO: Implement runtime normalization on shows and seasons"
      end
    end

    context "descending" do
      it "orders by runtime descending" do
        skip "TODO: Implement runtime normalization on shows and seasons"
      end
    end
  end

  describe ".ordered_by_popularity" do
    context "ascending" do
      it "orders by popularity ascending" do
        skip "TODO: Implement popularity sorting"
      end
    end

    context "descending" do
      it "orders by popularity descending" do
        skip "TODO: Implement popularity sorting"
      end
    end
  end

  describe ".ordered_by_overall_rating" do
    context "ascending" do
      it "orders by overall rating ascending" do
        skip "TODO: Implement overall rating sorting"
      end
    end

    context "descending" do
      it "orders by overall rating descending" do
        skip "TODO: Implement overall rating sorting"
      end
    end
  end
end
