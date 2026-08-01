require "rails_helper"

module Filters
  RSpec.describe Franchises do
    describe "#filter" do
      let(:instance) { Franchises.new(options) }

      subject { instance.filter }

      context "when filtering by release dates" do
        let(:options) { {release_dates_from: "2025-01-01", release_dates_to: "2025-01-02"} }

        before do
          show1 = FactoryBot.create(:show)
          season = FactoryBot.create(:season, show: show1)
          FactoryBot.create(:episode, season:, number: 1, original_air_date: "2025-01-01")
          @franchise1 = FactoryBot.create(:franchise)
          FactoryBot.create(:franchise_item, franchise: @franchise1, record: show1)

          show2 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-02")
          show_with_date_not_in_range = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-03")
          @franchise2 = FactoryBot.create(:franchise)
          FactoryBot.create(:franchise_item, franchise: @franchise2, record: show2)
          FactoryBot.create(:franchise_item, franchise: @franchise2, record: show_with_date_not_in_range)

          show3 = FactoryBot.create(:show)
          season = show3.seasons.first # Special season, not counted
          FactoryBot.create(:episode, season:, number: 1, original_air_date: "2025-01-02")
          @franchise3 = FactoryBot.create(:franchise)
          FactoryBot.create(:franchise_item, franchise: @franchise3, record: show3)

          show4 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-03") # Outside of range
          @franchise4 = FactoryBot.create(:franchise)
          FactoryBot.create(:franchise_item, franchise: @franchise4, record: show4)

          FactoryBot.create(:franchise) # No items
        end

        it "only returns franchises that have an item that released within the dates given" do
          expect(subject.length).to eq 2
          expect(subject).to include(@franchise1)
          expect(subject).to include(@franchise2)
        end

        it "includes the count of items within the range" do
          expect(@franchise2.franchise_items.count).to eq 2
          franchises = subject
          expect(franchises).to include(@franchise2)
          franchises.each do |franchise|
            # Franchise 2 has an item count of 2 as proved above, but one of the items is not in the range
            expect(franchise.items_count).to eq 1
          end
        end
      end

      context "when there are no filters" do
        let(:options) { {} }

        before do
          @franchise1 = FactoryBot.create(:franchise)
          @franchise2 = FactoryBot.create(:franchise)
          @franchise3 = FactoryBot.create(:franchise)
        end

        it "returns all franchises" do
          expect(subject.length).to eq 3
          expect(subject).to include(@franchise1)
          expect(subject).to include(@franchise2)
          expect(subject).to include(@franchise3)
        end
      end
    end

    describe "#to_params" do
      let(:instance) { Franchises.new(options) }
      let(:options) {
        {
          release_dates_from:,
          release_dates_to:
        }
      }
      let(:release_dates_from) { "2025-01-01" }
      let(:release_dates_to) { "2025-01-02" }

      subject { instance.to_params }

      it "converts the options to params" do
        expect(subject).to eq({
          release_dates_from:,
          release_dates_to:
        })
      end

      context "when release dates from is not present" do
        let(:release_dates_from) { nil }

        it "does not include the release date from" do
          expect(subject).to eq({
            release_dates_to:
          })
        end
      end

      context "when release dates to is not present" do
        let(:release_dates_to) { nil }

        it "does not include the release date to" do
          expect(subject).to eq({
            release_dates_from:
          })
        end
      end
    end
  end
end
