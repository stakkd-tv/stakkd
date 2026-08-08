require "rails_helper"

module Manage
  RSpec.describe History do
    include ActiveSupport::Testing::TimeHelpers

    let(:user) { FactoryBot.create(:user) }
    let(:history) { History.new(user) }

    describe "#add!" do
      let(:episode1) { FactoryBot.create(:episode) }
      let(:episode2) { FactoryBot.create(:episode) }
      let(:items) { [episode1, episode2] }
      let(:consumed_at) { DateTime.new(2026, 1, 1, 10) }

      subject { history.add!(items, consumed_at:) }

      before do
        travel_to(Time.current)
      end

      it "adds to the users history for each item" do
        subject
        expect(user.history_items.count).to eq 2
        first_item = user.history_items.first
        expect(first_item.item).to eq episode1
        expect(first_item.consumed_at).to eq consumed_at
        expect(first_item.created_at).to eq Time.current
        expect(first_item.updated_at).to eq Time.current
        second_item = user.history_items.second
        expect(second_item.item).to eq episode2
        expect(second_item.consumed_at).to eq consumed_at
        expect(second_item.created_at).to eq Time.current
        expect(second_item.updated_at).to eq Time.current
      end

      it "executes inserts in batches" do
        stub_const("Manage::History::BATCH_SIZE", 1)
        expect(HistoryItem).to receive(:insert_all!).with([
          {
            user_id: user.id,
            item_type: "Episode",
            item_id: episode1.id,
            consumed_at:,
            created_at: Time.current,
            updated_at: Time.current
          }
        ]).and_call_original
        expect(HistoryItem).to receive(:insert_all!).with([
          {
            user_id: user.id,
            item_type: "Episode",
            item_id: episode2.id,
            consumed_at:,
            created_at: Time.current,
            updated_at: Time.current
          }
        ]).and_call_original
        subject
        expect(user.history_items.count).to eq 2
      end

      context "when consumed_at is :release_date" do
        let(:consumed_at) { :release_date }
        let(:episode) { FactoryBot.create(:episode, original_air_date: Date.new(2026, 2, 2)) }
        let(:items) { [episode] }

        it "sets the consumed_at for each history item to the items release date" do
          subject
          expect(user.history_items.first.consumed_at).to eq episode.original_air_date
        end
      end
    end
  end
end
