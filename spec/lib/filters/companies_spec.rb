require "rails_helper"

module Filters
  RSpec.describe Companies do
    describe "#filter" do
      let(:instance) { Companies.new(options) }

      subject { instance.filter }

      context "when country id filter is given" do
        let(:country) { FactoryBot.create(:country) }
        let(:options) { {country_id: country.id} }

        before do
          @company1 = FactoryBot.create(:company, name: "Z", country:)
          @company2 = FactoryBot.create(:company, name: "A", country:)
          FactoryBot.create(:company)
        end

        it "only returns companies for that country ordered by name" do
          expect(subject).to eq [@company2, @company1]
        end
      end

      context "when there are no filters" do
        let(:options) { {} }

        before do
          @company1 = FactoryBot.create(:company, name: "Z")
          @company2 = FactoryBot.create(:company, name: "B")
          @company3 = FactoryBot.create(:company, name: "A")
        end

        it "returns all movies ordered by name" do
          expect(subject).to eq [@company3, @company2, @company1]
        end
      end
    end

    describe "#to_params" do
      let(:instance) { Companies.new(options) }
      let(:options) {
        {
          country_id:
        }
      }
      let(:country_id) { 1 }

      subject { instance.to_params }

      it "converts the options to params" do
        expect(subject).to eq({
          country_id:
        })
      end

      context "when country_id is not present" do
        let(:country_id) { nil }

        it "does not include the country_id" do
          expect(subject).to eq({})
        end
      end
    end
  end
end
