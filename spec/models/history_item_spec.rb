require "rails_helper"

RSpec.describe HistoryItem, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:item) }
  end

  describe ".recently_consumed" do
    it "orders by consumed at descending with nulls last" do
      unknown_date = FactoryBot.create(:history_item, consumed_at: nil)
      history_item1 = FactoryBot.create(:history_item, consumed_at: Time.current - 1.second)
      history_item2 = FactoryBot.create(:history_item, consumed_at: Time.current)
      ordered_items = HistoryItem.recently_consumed
      expect(ordered_items).to eq([history_item2, history_item1, unknown_date])
    end
  end
end
