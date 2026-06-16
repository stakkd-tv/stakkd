require "rails_helper"

module Pagination
  RSpec.describe Seasons, type: :presenter do
    let(:season) { FactoryBot.create(:season, number: 2) }
    let(:pagination) { Seasons.new(season, season.show) }

    describe "#next_item" do
      context "when there is a next season" do
        let!(:next_season) { FactoryBot.create(:season, number: season.number + 1, show: season.show) }

        it "returns the next season" do
          expect(pagination.next_item).to eq(next_season)
        end
      end

      context "when there is no next season" do
        it "returns nil" do
          expect(pagination.next_item).to be_nil
        end
      end
    end

    describe "#previous_item" do
      context "when there is a previous season" do
        let!(:previous_season) { FactoryBot.create(:season, number: season.number - 1, show: season.show) }

        it "returns the previous season" do
          expect(pagination.previous_item).to eq(previous_season)
        end
      end

      context "when there is no previous season" do
        it "returns nil" do
          expect(pagination.previous_item).to be_nil
        end
      end
    end

    describe "#next_item_path" do
      let!(:next_season) { FactoryBot.create(:season, number: season.number + 1, show: season.show) }

      it "returns the path to the next season" do
        expect(pagination.next_item_path).to eq(show_season_path(next_season, show_id: season.show))
      end
    end

    describe "#previous_item_path" do
      let!(:previous_season) { FactoryBot.create(:season, number: season.number - 1, show: season.show) }

      it "returns the path to the previous season" do
        expect(pagination.previous_item_path).to eq(show_season_path(previous_season, show_id: season.show))
      end
    end

    describe "#items" do
      let!(:other_season) { season.show.ordered_seasons.first }

      it "returns the items" do
        expect(pagination.items.count).to eq 2

        first_item = pagination.items.first
        expect(first_item.name).to eq "Specials"
        expect(first_item.path).to eq show_season_path(other_season, show_id: other_season.show)
        expect(first_item.selected).to be_falsey

        second_item = pagination.items.last
        expect(second_item.name).to eq "Season #{season.number}"
        expect(second_item.path).to eq show_season_path(season, show_id: season.show)
        expect(second_item.selected).to be_truthy
      end
    end
  end
end
