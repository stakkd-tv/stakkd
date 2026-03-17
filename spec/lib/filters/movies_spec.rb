require "rails_helper"

module Filters
  RSpec.describe Movies do
    describe "#filter" do
      let(:instance) { Movies.new(options) }

      subject { instance.filter }

      context "when sort is not a valid sort" do
        let(:options) { {sort: "bogus maloney"} }

        before do
          @movie1 = FactoryBot.create(:movie, translated_title: "Z")
          @movie2 = FactoryBot.create(:movie, translated_title: "A")
        end

        it "sorts movies by title" do
          expect(subject).to eq [@movie2, @movie1]
        end
      end

      context "when sort is translated_title" do
        let(:options) { {sort: "translated_title"} }

        before do
          @movie1 = FactoryBot.create(:movie, translated_title: "Z")
          @movie2 = FactoryBot.create(:movie, translated_title: "A")
        end

        it "sorts movies by title" do
          expect(subject).to eq [@movie2, @movie1]
        end
      end

      context "when sort is release_date" do
        let(:options) { {sort: "release_date"} }

        before do
          @movie1 = FactoryBot.create(:movie, :with_release_date, translated_title: "A", date_for_release: Date.new(2023, 1, 1))
          @movie2 = FactoryBot.create(:movie, :with_release_date, translated_title: "Z", date_for_release: Date.new(2022, 1, 1))
        end

        it "sorts movies by release date" do
          expect(subject).to eq [@movie2, @movie1]
        end
      end

      context "when sort is popularity" do
        let(:options) { {sort: "popularity"} }

        it "sorts movies by popularity" do
          skip "TODO: popularity sorting is not implemented yet"
        end
      end

      context "when sort is rating" do
        let(:options) { {sort: "popularity"} }

        it "sorts movies by rating" do
          skip "TODO: rating sorting is not implemented yet"
        end
      end

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

      context "when company filters are given" do
        let(:disney) { FactoryBot.create(:company, name: "Disney") }
        let(:cartoon_network) { FactoryBot.create(:company, name: "Cartoon Network") }
        let(:youtube) { FactoryBot.create(:company, name: "YouTube") }
        let(:nicktoons) { FactoryBot.create(:company, name: "Nicktoons") }
        let(:options) { {company_ids: [disney.id, youtube.id]} }

        before do
          @movie = FactoryBot.create(:movie, companies: [youtube, nicktoons, disney])
          FactoryBot.create(:movie, companies: [disney])
          FactoryBot.create(:movie, companies: [cartoon_network, youtube])
        end

        it "returns only the shows that include all given companies" do
          expect(subject).to eq [@movie]
        end
      end

      context "when certification filters are given" do
        let(:country) { FactoryBot.create(:country) }
        let(:uk_pg) { FactoryBot.create(:certification, code: "PG", country: country) }
        let(:uk_nr) { FactoryBot.create(:certification, code: "NR", country: country) }
        let(:uk_18) { FactoryBot.create(:certification, code: "18", country: country) }
        let(:uk_r) { FactoryBot.create(:certification, code: "R", country: country) }
        let(:options) { {certification_ids: [uk_pg.id, uk_18.id]} }

        before do
          @movie = FactoryBot.create(:movie)
          [uk_18, uk_r, uk_pg].each do |certification|
            FactoryBot.create(:release, movie: @movie, certification:)
          end
          @movie2 = FactoryBot.create(:movie)
          FactoryBot.create(:release, movie: @movie2, certification: uk_pg)
          @movie3 = FactoryBot.create(:movie)
          [uk_nr, uk_18].each do |certification|
            FactoryBot.create(:release, movie: @movie3, certification:)
          end
          @movie4 = FactoryBot.create(:movie)
          FactoryBot.create(:release, movie: @movie4, certification: uk_nr)
        end

        it "returns any show that include any of the given certifications" do
          expect(subject.count).to eq 3
          expect(subject).to include(@movie)
          expect(subject).to include(@movie2)
          expect(subject).to include(@movie3)
        end
      end

      context "when keyword filters are given" do
        let(:options) { {keywords: ["nonsense", "nope"]} }

        before do
          @movie = FactoryBot.create(:movie, keyword_list: ["nonsense", "nope"])
          @movie2 = FactoryBot.create(:movie, keyword_list: ["nope"])
          @movie3 = FactoryBot.create(:movie)
        end

        it "only returns shows with the keywords" do
          expect(subject).to eq [@movie]
        end

        context "when there is a blank string" do
          let(:options) { {keywords: [""]} }

          it "treats it as a nil value" do
            expect(subject.count).to eq 3
            expect(subject).to include(@movie)
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
          release_type:,
          company_ids:,
          certification_ids:,
          keywords:,
          sort:
        }
      }
      let(:country_id) { 1 }
      let(:genre_ids) { [1] }
      let(:release_date_from) { "2025-01-01" }
      let(:release_date_to) { "2025-01-02" }
      let(:release_type) { Release::DIGITAL }
      let(:company_ids) { [1] }
      let(:certification_ids) { [1] }
      let(:keywords) { ["lol"] }
      let(:sort) { "translated_title" }

      subject { instance.to_params }

      it "converts the options to params" do
        expect(subject).to eq({
          country_id:,
          genre_ids:,
          release_date_from:,
          release_date_to:,
          release_type:,
          company_ids:,
          certification_ids:,
          keywords:,
          sort:
        })
      end

      context "when country id is not present" do
        let(:country_id) { nil }

        it "does not include the country id" do
          expect(subject).to eq({
            genre_ids:,
            release_date_from:,
            release_date_to:,
            release_type:,
            company_ids:,
            certification_ids:,
            keywords:,
            sort:
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
            release_type:,
            company_ids:,
            certification_ids:,
            keywords:,
            sort:
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
            release_type:,
            company_ids:,
            certification_ids:,
            keywords:,
            sort:
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
            release_type:,
            company_ids:,
            certification_ids:,
            keywords:,
            sort:
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
            release_date_to:,
            company_ids:,
            certification_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when company ids are not present" do
        let(:company_ids) { [] }

        it "does not include the company ids" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            release_date_from:,
            release_date_to:,
            release_type:,
            certification_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when certification ids are not present" do
        let(:certification_ids) { [] }

        it "does not include the certification ids" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            release_date_from:,
            release_date_to:,
            release_type:,
            company_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when keywords are not present" do
        let(:keywords) { [""] }

        it "does not include the keywords" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            release_date_from:,
            release_date_to:,
            release_type:,
            company_ids:,
            certification_ids:,
            sort:
          })
        end
      end

      context "when sort is not valid" do
        let(:sort) { nil }

        it "defaults to translated_title" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            release_date_from:,
            release_date_to:,
            release_type:,
            company_ids:,
            certification_ids:,
            keywords:,
            sort: "translated_title"
          })
        end
      end
    end

    describe "#sorting_options" do
      subject { Movies.new({}).sorting_options }

      it "returns an array of valid sorting options" do
        expect(subject).to eq([
          {name: "Title", value: "translated_title"},
          {name: "Release Date", value: "release_date"},
          {name: "Popularity", value: "popularity"},
          {name: "Rating", value: "rating"}
        ])
      end
    end
  end
end
