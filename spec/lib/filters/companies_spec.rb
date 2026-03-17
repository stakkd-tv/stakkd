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
          @company = FactoryBot.create(:company, country:)
          FactoryBot.create(:company)
        end

        it "only returns companies for that country" do
          expect(subject).to eq [@company]
        end
      end

      context "when there are no filters" do
        let(:options) { {} }

        before do
          @company1 = FactoryBot.create(:company)
          @company2 = FactoryBot.create(:company)
          @company3 = FactoryBot.create(:company)
        end

        it "returns all movies" do
          expect(subject.length).to eq 3
          expect(subject).to include(@company1)
          expect(subject).to include(@company2)
          expect(subject).to include(@company3)
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
