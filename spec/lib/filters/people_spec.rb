require "rails_helper"

module Filters
  RSpec.describe People do
    describe "#filter" do
      let(:instance) { People.new(options) }

      subject { instance.filter }

      context "when sort is not a valid sort" do
        let(:options) { {sort: "bogus maloney"} }

        before do
          @people1 = FactoryBot.create(:person, translated_name: "Z")
          @people2 = FactoryBot.create(:person, translated_name: "A")
        end

        it "sorts people by name" do
          expect(subject).to eq [@people2, @people1]
        end
      end

      context "when sort is translated_name" do
        let(:options) { {sort: "translated_name"} }

        before do
          @people1 = FactoryBot.create(:person, translated_name: "Z")
          @people2 = FactoryBot.create(:person, translated_name: "A")
        end

        it "sorts people by name" do
          expect(subject).to eq [@people2, @people1]
        end
      end

      context "when sort is popularity" do
        let(:options) { {sort: "popularity"} }

        it "sorts people by popularity" do
          skip "TODO: popularity sorting is not implemented yet"
        end
      end

      context "when sort is age" do
        let(:options) { {sort: "age"} }

        before do
          @people1 = FactoryBot.create(:person, dob: Date.new(1990, 1, 1))
          @people2 = FactoryBot.create(:person, dob: Date.new(2000, 1, 1))
          @people3 = FactoryBot.create(:person, dob: Date.new(1990, 1, 1), dod: Date.new(1991, 1, 1))
          @people4 = FactoryBot.create(:person, dob: nil)
        end

        it "sorts people by age" do
          expect(subject).to eq [@people3, @people2, @people1, @people4]
        end
      end

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
          @person1 = FactoryBot.create(:person, gender: Person::FEMALE, known_for: Person::ACTING, dob: "2025-01-01", translated_name: "Z")
          @person2 = FactoryBot.create(:person, gender: Person::FEMALE, known_for: Person::ACTING, dob: "2025-01-01", translated_name: "A")
          FactoryBot.create(:person, gender: Person::FEMALE, known_for: Person::WRITING, dob: "2025-01-01")
          FactoryBot.create(:person, gender: Person::FEMALE, known_for: Person::ACTING, dob: "2025-01-02")
          FactoryBot.create(:person, gender: Person::MALE, known_for: Person::ACTING, dob: "2025-01-01")
        end

        it "applies the filter and sorting" do
          expect(subject).to eq [@person2, @person1]
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
          birthday_to:,
          sort:
        }
      }
      let(:gender) { "Male" }
      let(:known_for) { "Acting" }
      let(:birthday_from) { "2025-01-01" }
      let(:birthday_to) { "2025-01-02" }
      let(:sort) { "translated_name" }

      subject { instance.to_params }

      it "converts the options to params" do
        expect(subject).to eq({
          gender:,
          known_for:,
          birthday_from:,
          birthday_to:,
          sort:
        })
      end

      context "when gender is not present" do
        let(:gender) { "" }

        it "does not include the gender" do
          expect(subject).to eq({
            known_for:,
            birthday_from:,
            birthday_to:,
            sort:
          })
        end
      end

      context "when known_for is not present" do
        let(:known_for) { "" }

        it "does not include the known_for" do
          expect(subject).to eq({
            gender:,
            birthday_from:,
            birthday_to:,
            sort:
          })
        end
      end

      context "when birthday from is not present" do
        let(:birthday_from) { nil }

        it "does not include the birthday from" do
          expect(subject).to eq({
            gender:,
            known_for:,
            birthday_to:,
            sort:
          })
        end
      end

      context "when birthday to is not present" do
        let(:birthday_to) { nil }

        it "does not include the birthday to" do
          expect(subject).to eq({
            gender:,
            known_for:,
            birthday_from:,
            sort:
          })
        end
      end

      context "when sort is not valid" do
        let(:sort) { nil }

        it "defaults to translated_name" do
          expect(subject).to eq({
            gender:,
            known_for:,
            birthday_from:,
            birthday_to:,
            sort: "translated_name"
          })
        end
      end
    end

    describe "#sorting_options" do
      subject { People.new({}).sorting_options }

      it "returns an array of valid sorting options" do
        expect(subject).to eq([
          {name: "Name", value: "translated_name"},
          {name: "Age", value: "age"},
          {name: "Popularity", value: "popularity"}
        ])
      end
    end
  end
end
