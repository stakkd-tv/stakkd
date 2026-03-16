require "rails_helper"

module Filters
  RSpec.describe People do
    describe "#filter" do
      let(:instance) { People.new(options) }

      subject { instance.filter }

      context "when gender filter is given" do
        let(:options) { {gender: Person::MALE} }

        before do
          @person = FactoryBot.create(:person, gender: Person::MALE)
          FactoryBot.create(:person, gender: Person::FEMALE)
        end

        it "only returns people for that gender" do
          expect(subject).to eq [@person]
        end
      end

      context "when known_for filter is given" do
        let(:options) { {known_for: Person::WRITING} }

        before do
          @person = FactoryBot.create(:person, known_for: Person::WRITING)
          FactoryBot.create(:person, known_for: Person::ACTING)
        end

        it "only returns people for that known_for" do
          expect(subject).to eq [@person]
        end
      end

      context "when filtering by birth date" do
        let(:options) { {birthday_from: "2025-01-01", birthday_to: "2025-01-02"} }

        before do
          @person1 = FactoryBot.create(:person, dob: "2025-01-01")
          @person2 = FactoryBot.create(:person, dob: "2025-01-02")
          FactoryBot.create(:person, dob: "2025-01-03")
        end

        it "only returns people within the birth date range" do
          expect(subject.length).to eq 2
          expect(subject).to include(@person1)
          expect(subject).to include(@person2)
        end
      end

      context "when multiple filters are given" do
        let(:action) { FactoryBot.create(:genre, name: "Action") }
        let(:animation) { FactoryBot.create(:genre, name: "Animation") }
        let(:horror) { FactoryBot.create(:genre, name: "Horror") }
        let(:comedy) { FactoryBot.create(:genre, name: "Comedy") }
        let(:options) {
          {
            gender: Person::FEMALE,
            known_for: Person::ACTING,
            birthday_from: "2025-01-01",
            birthday_to: "2025-01-01"
          }
        }

        before do
          @person = FactoryBot.create(:person, gender: Person::FEMALE, known_for: Person::ACTING, dob: "2025-01-01")
          FactoryBot.create(:person, gender: Person::FEMALE, known_for: Person::WRITING, dob: "2025-01-01")
          FactoryBot.create(:person, gender: Person::FEMALE, known_for: Person::ACTING, dob: "2025-01-02")
          FactoryBot.create(:person, gender: Person::MALE, known_for: Person::ACTING, dob: "2025-01-01")
        end

        it "applies the filter" do
          expect(subject).to eq [@person]
        end
      end

      context "when there are no filters" do
        let(:options) { {} }

        before do
          @person1 = FactoryBot.create(:person)
          @person2 = FactoryBot.create(:person)
          @person3 = FactoryBot.create(:person)
        end

        it "returns all movies" do
          expect(subject.length).to eq 3
          expect(subject).to include(@person1)
          expect(subject).to include(@person2)
          expect(subject).to include(@person3)
        end
      end
    end

    describe "#to_params" do
      let(:instance) { People.new(options) }
      let(:options) {
        {
          gender:,
          known_for:,
          birthday_from:,
          birthday_to:
        }
      }
      let(:gender) { "Male" }
      let(:known_for) { "Acting" }
      let(:birthday_from) { "2025-01-01" }
      let(:birthday_to) { "2025-01-02" }

      subject { instance.to_params }

      it "converts the options to params" do
        expect(subject).to eq({
          gender:,
          known_for:,
          birthday_from:,
          birthday_to:
        })
      end

      context "when gender is not present" do
        let(:gender) { "" }

        it "does not include the gender" do
          expect(subject).to eq({
            known_for:,
            birthday_from:,
            birthday_to:
          })
        end
      end

      context "when known_for is not present" do
        let(:known_for) { "" }

        it "does not include the known_for" do
          expect(subject).to eq({
            gender:,
            birthday_from:,
            birthday_to:
          })
        end
      end

      context "when birthday from is not present" do
        let(:birthday_from) { nil }

        it "does not include the birthday from" do
          expect(subject).to eq({
            gender:,
            known_for:,
            birthday_to:
          })
        end
      end

      context "when birthday to is not present" do
        let(:birthday_to) { nil }

        it "does not include the birthday to" do
          expect(subject).to eq({
            gender:,
            known_for:,
            birthday_from:
          })
        end
      end
    end
  end
end
