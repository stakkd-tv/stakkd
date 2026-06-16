require "rails_helper"

module Pagination
  RSpec.describe Episodes, type: :presenter do
    let(:episode) { FactoryBot.create(:episode, number: 2) }
    let(:pagination) { Episodes.new(episode, episode.season, episode.show) }

    describe "#next_item" do
      context "when there is a next episode" do
        let!(:next_episode) { FactoryBot.create(:episode, season: episode.season, number: episode.number + 1) }

        it "returns the next episode" do
          expect(pagination.next_item).to eq(next_episode)
        end
      end

      context "when there is no next episode" do
        it "returns nil" do
          expect(pagination.next_item).to be_nil
        end
      end
    end

    describe "#previous_item" do
      context "when there is a previous episode" do
        let!(:previous_episode) { FactoryBot.create(:episode, season: episode.season, number: episode.number - 1) }

        it "returns the previous episode" do
          expect(pagination.previous_item).to eq(previous_episode)
        end
      end

      context "when there is no previous episode" do
        it "returns nil" do
          expect(pagination.next_item).to be_nil
        end
      end
    end

    describe "#next_item_path" do
      let!(:next_episode) { FactoryBot.create(:episode, season: episode.season, number: episode.number + 1) }

      it "returns the path to the next episode" do
        expect(pagination.next_item_path).to eq(show_season_episode_path(episode.next_episode, season_id: episode.season, show_id: episode.show))
      end
    end

    describe "#previous_item_path" do
      let!(:previous_episode) { FactoryBot.create(:episode, season: episode.season, number: episode.number - 1) }

      it "returns the path to the previous episode" do
        expect(pagination.previous_item_path).to eq(show_season_episode_path(previous_episode, season_id: episode.season, show_id: episode.show))
      end
    end

    describe "#items" do
      let!(:other_episode) { FactoryBot.create(:episode, season: episode.season, number: episode.number + 1) }

      it "returns the items" do
        expect(pagination.items.count).to eq 2

        first_item = pagination.items.first
        expect(first_item.name).to eq "Episode #{episode.number}"
        expect(first_item.path).to eq show_season_episode_path(episode, season_id: episode.season, show_id: episode.show)
        expect(first_item.selected).to be_truthy

        second_item = pagination.items.last
        expect(second_item.name).to eq "Episode #{other_episode.number}"
        expect(second_item.path).to eq show_season_episode_path(other_episode, season_id: episode.season, show_id: episode.show)
        expect(second_item.selected).to be_falsey
      end
    end
  end
end
