require "rails_helper"

module Manage
  RSpec.describe History do
    include ActiveSupport::Testing::TimeHelpers

    let(:user) { FactoryBot.create(:user) }
    let(:history) { History.new(user) }

    describe "#add!" do
      let(:episode1) { item.ordered_episodes.first }
      let(:episode2) { item.ordered_episodes.second }
      let(:item) {
        FactoryBot.create(
          :season,
          episodes: [
            FactoryBot.build(:episode, number: 1, original_air_date: Date.today),
            FactoryBot.build(:episode, number: 2, original_air_date: Date.today)
          ]
        )
      }
      let(:consumed_at) { DateTime.new(2026, 1, 1, 10) }

      subject { history.add!(item, consumed_at:) }

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
        let(:item) { episode.season }

        it "sets the consumed_at for each history item to the items release date" do
          subject
          expect(user.history_items.first.consumed_at).to eq episode.original_air_date
        end
      end
    end

    describe "#status_for" do
      subject { history.status_for(item) }

      context "when user is nil" do
        let(:user) { nil }
        let(:item) { FactoryBot.create(:movie) }

        it { should eq :not_watched }
      end

      context "when item is a movie" do
        let(:item) { FactoryBot.create(:movie) }

        context "when item has not been added to history" do
          it { should eq :not_watched }
        end

        context "when item has been added to history" do
          before do
            FactoryBot.create(:history_item, user:, item:)
          end

          it { should eq :watched }
        end
      end

      context "when item is an episode" do
        let(:item) { FactoryBot.create(:episode) }

        context "when item has not been added to history" do
          it { should eq :not_watched }
        end

        context "when item has been added to history" do
          before do
            FactoryBot.create(:history_item, user:, item:)
          end

          it { should eq :watched }
        end
      end

      context "when item is a season" do
        let(:item) { FactoryBot.create(:season, :with_premiere_date) }
        let!(:episode1) { item.episodes.first }
        let!(:episode2) { FactoryBot.create(:episode, season: item, number: episode1.number + 1) }

        context "when no episodes have been watched" do
          it { should eq :not_watched }
        end

        context "when item has been partially added to history" do
          before do
            FactoryBot.create(:history_item, user:, item: episode2)
          end

          it { should eq :partially_watched }
        end

        context "when an episode has been watched multiple times" do
          before do
            # Item watched the same amount of times as there are episodes, but only counted once
            FactoryBot.create(:history_item, user:, item: episode2)
            FactoryBot.create(:history_item, user:, item: episode2)
          end

          it { should eq :partially_watched }
        end

        context "when all episodes have been added to history" do
          before do
            FactoryBot.create(:history_item, user:, item: episode1)
            FactoryBot.create(:history_item, user:, item: episode2)
          end

          it { should eq :watched }
        end
      end

      context "when item is a show" do
        let(:item) { FactoryBot.create(:show, :with_premiere_date) }
        let(:season) { item.ordered_seasons.last }
        let(:episode1) { season.episodes.first }
        let(:episode2) { FactoryBot.create(:episode, season:, number: episode1.number + 1) }

        context "when item has not been added to history" do
          it { should eq :not_watched }
        end

        context "when item has been partially added to history" do
          before do
            FactoryBot.create(:history_item, user:, item: episode2)
          end

          it { should eq :partially_watched }
        end

        context "when an episode has been watched multiple times" do
          before do
            # Item watched the same amount of times as there are episodes, but only counted once
            FactoryBot.create(:history_item, user:, item: episode2)
            FactoryBot.create(:history_item, user:, item: episode2)
          end

          it { should eq :partially_watched }
        end

        context "when all episodes have been added to history" do
          before do
            FactoryBot.create(:history_item, user:, item: episode1)
            FactoryBot.create(:history_item, user:, item: episode2)
          end

          it { should eq :watched }
        end
      end
    end

    describe "#statuses_for" do
      subject { history.statuses_for(items) }

      context "when user is nil" do
        let(:user) { nil }
        let(:movie) { FactoryBot.create(:movie, :with_release_date) }
        let(:items) { [movie] }

        it { should eq({movie => :not_watched}) }
      end

      context "when items are nil" do
        let(:items) { nil }

        it { should eq({}) }
      end

      context "when items is empty" do
        let(:items) { [] }

        it { should eq({}) }
      end

      context "with movies (atomic)" do
        let(:movie1) { FactoryBot.create(:movie, :with_release_date) }
        let(:movie2) { FactoryBot.create(:movie, :with_release_date) }
        let(:items) { [movie1, movie2] }

        context "when there is no history for the movies" do
          it { should eq({movie1 => :not_watched, movie2 => :not_watched}) }
        end

        context "when user has added some of the movies to history" do
          before do
            FactoryBot.create(:history_item, user:, item: movie1)
            FactoryBot.create(:history_item, user:, item: movie1)
          end

          it { should eq({movie1 => :watched, movie2 => :not_watched}) }
        end

        context "when user has added all movies to history" do
          before do
            FactoryBot.create(:history_item, user:, item: movie1)
            FactoryBot.create(:history_item, user:, item: movie2)
          end

          it { should eq({movie1 => :watched, movie2 => :watched}) }
        end
      end

      context "with episodes (atomic)" do
        let(:episode1) { FactoryBot.create(:episode) }
        let(:episode2) { FactoryBot.create(:episode) }
        let(:items) { [episode1, episode2] }

        context "when there is no history for the episodes" do
          it { should eq({episode1 => :not_watched, episode2 => :not_watched}) }
        end

        context "when user has added some of the episodes to history" do
          before do
            FactoryBot.create(:history_item, user:, item: episode1)
            FactoryBot.create(:history_item, user:, item: episode1)
          end

          it { should eq({episode1 => :watched, episode2 => :not_watched}) }
        end

        context "when user has added all episodes to history" do
          before do
            FactoryBot.create(:history_item, user:, item: episode1)
            FactoryBot.create(:history_item, user:, item: episode2)
          end

          it { should eq({episode1 => :watched, episode2 => :watched}) }
        end
      end

      context "with seasons (container)" do
        context "when there are no released episodes" do
          let(:season1) { FactoryBot.create(:season) }
          let(:season2) { FactoryBot.create(:season) }
          let(:items) { [season1, season2] }

          it { should eq({season1 => :not_watched, season2 => :not_watched}) }
        end

        context "when user has no history items for episodes in the season" do
          let(:season1) { FactoryBot.create(:season, :with_premiere_date) }
          let(:season2) { FactoryBot.create(:season, :with_premiere_date) }
          let(:items) { [season1, season2] }

          it { should eq({season1 => :not_watched, season2 => :not_watched}) }
        end

        context "when user has history items for some (not all) episodes in the season" do
          let(:season) { FactoryBot.create(:season, :with_premiere_date) }
          let(:episode1) { season.ordered_episodes.first }
          let(:episode2) { FactoryBot.create(:episode, season:, number: episode1.number + 1) }
          let(:items) { [season] }

          before do
            HistoryItem.create(user:, item: episode2)
            HistoryItem.create(user:, item: episode2)
          end

          it { should eq({season => :partially_watched}) }
        end

        context "when user has history items for all released episodes in the season" do
          let(:season) { FactoryBot.create(:season, :with_premiere_date) }
          let(:episode1) { season.ordered_episodes.first }
          let(:episode2) { FactoryBot.create(:episode, season:, number: episode1.number + 1) }
          let(:items) { [season] }

          before do
            HistoryItem.create(user:, item: episode1)
            HistoryItem.create(user:, item: episode2)
          end

          it { should eq({season => :watched}) }
        end

        context "when evaluating multiple seasons with different statuses" do
          let(:season1) { FactoryBot.create(:season, :with_premiere_date) }
          let!(:episode) { FactoryBot.create(:episode, season: season1, number: 2) }
          let(:season2) { FactoryBot.create(:season, :with_premiere_date) }
          let(:season3) { FactoryBot.create(:season, :with_premiere_date) }
          let(:items) { [season1, season2, season3] }

          before do
            FactoryBot.create(:history_item, user:, item: season1.ordered_episodes.first)
            FactoryBot.create(:history_item, user:, item: season2.ordered_episodes.first)
          end

          it { should eq({season1 => :partially_watched, season2 => :watched, season3 => :not_watched}) }
        end
      end

      context "with shows (container)" do
        context "when there are no released episodes" do
          let(:show1) { FactoryBot.create(:show) }
          let(:show2) { FactoryBot.create(:show) }
          let(:items) { [show1, show2] }

          it { should eq({show1 => :not_watched, show2 => :not_watched}) }
        end

        context "when there are no history items for any episodes in the show" do
          let(:show1) { FactoryBot.create(:show, :with_premiere_date) }
          let(:show2) { FactoryBot.create(:show, :with_premiere_date) }
          let(:items) { [show1, show2] }

          it { should eq({show1 => :not_watched, show2 => :not_watched}) }
        end

        context "when user has watched some episodes across seasons" do
          let(:show) { FactoryBot.create(:show, :with_premiere_date) }
          let(:season1) { show.seasons_without_specials.ordered.first }
          let(:season2) { FactoryBot.create(:season, :with_premiere_date, show:, number: 2) }
          let(:items) { [show] }

          before do
            FactoryBot.create(:history_item, user:, item: season2.episodes.first)
          end

          it { should eq({show => :partially_watched}) }
        end

        context "when user has watched all releases episodes" do
          let(:show) { FactoryBot.create(:show, :with_premiere_date) }
          let(:season1) { show.seasons_without_specials.ordered.first }
          let(:season2) { FactoryBot.create(:season, :with_premiere_date, show:, number: 2) }
          let(:items) { [show] }

          before do
            FactoryBot.create(:history_item, user:, item: season1.episodes.first)
            FactoryBot.create(:history_item, user:, item: season2.episodes.first)
          end

          it { should eq({show => :watched}) }
        end

        context "when evaluating multiple shows with mixed statuses" do
          let(:show1) { FactoryBot.create(:show, :with_premiere_date) }
          let!(:episode) { FactoryBot.create(:episode, season: show1.seasons_without_specials.ordered.first, number: 2) }
          let(:show2) { FactoryBot.create(:show, :with_premiere_date) }
          let(:show3) { FactoryBot.create(:show, :with_premiere_date) }
          let(:items) { [show1, show2, show3] }

          before do
            FactoryBot.create(:history_item, user:, item: show1.non_special_episodes.ordered.first)
            FactoryBot.create(:history_item, user:, item: show2.non_special_episodes.ordered.first)
          end

          it { should eq({show1 => :partially_watched, show2 => :watched, show3 => :not_watched}) }
        end
      end

      context "with a mix of different model types" do
        let(:movie) { FactoryBot.create(:movie, :with_release_date) }
        let(:episode) { FactoryBot.create(:episode) }
        let(:items) { [movie, episode] }

        before do
          FactoryBot.create(:history_item, user:, item: movie)
        end

        it { should eq({movie => :watched, episode => :not_watched}) }
      end
    end
  end
end
