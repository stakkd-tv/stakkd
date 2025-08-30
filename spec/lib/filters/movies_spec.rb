require "rails_helper"

module Filters
  RSpec.describe Movies do
    describe "#filter" do
      let(:instance) { Movies.new(options) }

      subject { instance.filter }

      context "when country filter is given" do
        let(:country) { FactoryBot.create(:country) }
        let(:options) { {country_id: country.id} }

        before do
          @movie = FactoryBot.create(:movie, country:)
          FactoryBot.create(:movie)
        end

        it "only returns movies for that country" do
          expect(subject).to eq [@movie]
        end
      end

      context "when genre filters are given" do
        let(:action) { FactoryBot.create(:genre, name: "Action") }
        let(:animation) { FactoryBot.create(:genre, name: "Animation") }
        let(:horror) { FactoryBot.create(:genre, name: "Horror") }
        let(:comedy) { FactoryBot.create(:genre, name: "Comedy") }
        let(:options) { {genre_ids: [action.id, horror.id]} }

        before do
          @movie = FactoryBot.create(:movie, genres: [horror, comedy, action])
          FactoryBot.create(:movie, genres: [action])
          FactoryBot.create(:movie, genres: [animation, horror])
        end

        it "returns only the movies that include all given genres" do
          expect(subject).to eq [@movie]
        end
      end

      context "when filtering by release dates" do
        context "when no release type is given" do
          let(:options) { {release_date_from: "2025-01-01", release_date_to: "2025-01-02"} }

          before do
            @movie1 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
            @movie2 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-02", type: Release::THEATRICAL)])
            FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-03", type: Release::PREMIERE)])
          end

          it "filters by all release types" do
            expect(subject.length).to eq 2
            expect(subject).to include(@movie1)
            expect(subject).to include(@movie2)
          end
        end

        context "when release type is not valid" do
          let(:options) {
            {
              release_date_from: "2025-01-01",
              release_date_to: "2025-01-02",
              release_type: "INVALID"
            }
          }

          before do
            @movie1 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
            @movie2 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-02", type: Release::THEATRICAL)])
            FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-03", type: Release::PREMIERE)])
          end

          it "filters by all release types" do
            expect(subject.length).to eq 2
            expect(subject).to include(@movie1)
            expect(subject).to include(@movie2)
          end
        end

        context "when valid release type is given" do
          let(:options) {
            {
              release_date_from: "2025-01-01",
              release_date_to: "2025-01-02",
              release_type: Release::DIGITAL
            }
          }

          before do
            @movie = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
            FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-02", type: Release::THEATRICAL)])
            FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-03", type: Release::DIGITAL)])
          end

          it "filters by the given release type" do
            expect(subject).to eq [@movie]
          end
        end

        context "when from date is given but no to" do
          let(:options) {
            {
              release_date_from: "2025-01-01",
              release_type: Release::DIGITAL
            }
          }

          before do
            @movie1 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
            @movie2 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-02", type: Release::THEATRICAL)])
            @movie3 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-03", type: Release::DIGITAL)])
          end

          it "doesn't apply the filter" do
            expect(subject.length).to eq 3
            expect(subject).to include(@movie1)
            expect(subject).to include(@movie2)
            expect(subject).to include(@movie3)
          end
        end

        context "when to date is given but no from" do
          let(:options) {
            {
              release_date_to: "2025-01-02",
              release_type: Release::DIGITAL
            }
          }

          before do
            @movie1 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
            @movie2 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-02", type: Release::THEATRICAL)])
            @movie3 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-03", type: Release::DIGITAL)])
          end

          it "doesn't apply the filter" do
            expect(subject.length).to eq 3
            expect(subject).to include(@movie1)
            expect(subject).to include(@movie2)
            expect(subject).to include(@movie3)
          end
        end

        context "when from date is valid but not to" do
          let(:options) {
            {
              release_date_from: "2025-01-01",
              release_date_to: "INVALID",
              release_type: Release::DIGITAL
            }
          }

          before do
            @movie1 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
            @movie2 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-02", type: Release::THEATRICAL)])
            @movie3 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-03", type: Release::DIGITAL)])
          end

          it "doesn't apply the filter" do
            expect(subject.length).to eq 3
            expect(subject).to include(@movie1)
            expect(subject).to include(@movie2)
            expect(subject).to include(@movie3)
          end
        end

        context "when to date is valid but not from" do
          let(:options) {
            {
              release_date_from: "INVALID",
              release_date_to: "2025-01-02",
              release_type: Release::DIGITAL
            }
          }

          before do
            @movie1 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
            @movie2 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-02", type: Release::THEATRICAL)])
            @movie3 = FactoryBot.create(:movie, releases: [FactoryBot.build(:release, date: "2025-01-03", type: Release::DIGITAL)])
          end

          it "doesn't apply the filter" do
            expect(subject.length).to eq 3
            expect(subject).to include(@movie1)
            expect(subject).to include(@movie2)
            expect(subject).to include(@movie3)
          end
        end
      end

      context "when multiple filters are given" do
        let(:action) { FactoryBot.create(:genre, name: "Action") }
        let(:animation) { FactoryBot.create(:genre, name: "Animation") }
        let(:horror) { FactoryBot.create(:genre, name: "Horror") }
        let(:comedy) { FactoryBot.create(:genre, name: "Comedy") }
        let(:options) {
          {
            genre_ids: [action.id],
            release_date_from: "2025-01-01",
            release_date_to: "2025-01-02"
          }
        }

        before do
          @movie = FactoryBot.create(:movie, genres: [horror, comedy, action], releases: [FactoryBot.build(:release, date: "2025-01-01", type: Release::DIGITAL)])
          FactoryBot.create(:movie, genres: [action])
          FactoryBot.create(:movie, genres: [animation, horror])
        end

        it "applies the filter" do
          expect(subject).to eq [@movie]
        end
      end

      context "when there are no filters" do
        let(:action) { FactoryBot.create(:genre, name: "Action") }
        let(:animation) { FactoryBot.create(:genre, name: "Animation") }
        let(:horror) { FactoryBot.create(:genre, name: "Horror") }
        let(:comedy) { FactoryBot.create(:genre, name: "Comedy") }
        let(:options) { {} }

        before do
          @movie1 = FactoryBot.create(:movie, genres: [horror, comedy, action])
          @movie2 = FactoryBot.create(:movie, genres: [action])
          @movie3 = FactoryBot.create(:movie, genres: [animation, horror])
        end

        it "returns all movies" do
          expect(subject.length).to eq 3
          expect(subject).to include(@movie1)
          expect(subject).to include(@movie2)
          expect(subject).to include(@movie3)
        end
      end
    end

    describe "#to_params" do
      let(:instance) { Movies.new(options) }
      let(:options) {
        {
          country_id:,
          genre_ids:,
          release_date_from:,
          release_date_to:,
          release_type:
        }
      }
      let(:country_id) { 1 }
      let(:genre_ids) { [1] }
      let(:release_date_from) { "2025-01-01" }
      let(:release_date_to) { "2025-01-02" }
      let(:release_type) { Release::DIGITAL }

      subject { instance.to_params }

      it "converts the options to params" do
        expect(subject).to eq({
          country_id:,
          genre_ids:,
          release_date_from:,
          release_date_to:,
          release_type:
        })
      end

      context "when country id is not present" do
        let(:country_id) { nil }

        it "does not include the country id" do
          expect(subject).to eq({
            genre_ids:,
            release_date_from:,
            release_date_to:,
            release_type:
          })
        end
      end

      context "when genre ids are not present" do
        let(:genre_ids) { nil }

        it "does not include the country id" do
          expect(subject).to eq({
            country_id:,
            release_date_from:,
            release_date_to:,
            release_type:
          })
        end
      end

      context "when release date from is not present" do
        let(:release_date_from) { nil }

        it "does not include the country id" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            release_date_to:,
            release_type:
          })
        end
      end

      context "when release date to is not present" do
        let(:release_date_to) { nil }

        it "does not include the country id" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            release_date_from:,
            release_type:
          })
        end
      end

      context "when release type is not present" do
        let(:release_type) { nil }

        it "does not include the country id" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            release_date_from:,
            release_date_to:
          })
        end
      end
    end
  end
end
