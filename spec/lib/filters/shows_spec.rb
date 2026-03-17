require "rails_helper"

module Filters
  RSpec.describe Shows do
    describe "#filter" do
      let(:instance) { Shows.new(options) }

      subject { instance.filter }

      context "when sort is not a valid sort" do
        let(:options) { {sort: "bogus maloney"} }

        before do
          @show1 = FactoryBot.create(:show, translated_title: "Z")
          @show2 = FactoryBot.create(:show, translated_title: "A")
        end

        it "sorts shows by title" do
          expect(subject).to eq [@show2, @show1]
        end
      end

      context "when sort is translated_title" do
        let(:options) { {sort: "translated_title"} }

        before do
          @show1 = FactoryBot.create(:show, translated_title: "Z")
          @show2 = FactoryBot.create(:show, translated_title: "A")
        end

        it "sorts shows by title" do
          expect(subject).to eq [@show2, @show1]
        end
      end

      context "when sort is premiere_date" do
        let(:options) { {sort: "premiere_date"} }

        before do
          @show1 = FactoryBot.create(:show, :with_premiere_date, translated_title: "A", date_for_premiere: Date.new(2023, 1, 1))
          @show2 = FactoryBot.create(:show, :with_premiere_date, translated_title: "Z", date_for_premiere: Date.new(2022, 1, 1))
        end

        it "sorts shows by premiere date" do
          expect(subject).to eq [@show2, @show1]
        end
      end

      context "when sort is popularity" do
        let(:options) { {sort: "popularity"} }

        it "sorts shows by popularity" do
          skip "TODO: popularity sorting is not implemented yet"
        end
      end

      context "when sort is rating" do
        let(:options) { {sort: "popularity"} }

        it "sorts shows by rating" do
          skip "TODO: rating sorting is not implemented yet"
        end
      end

      context "when country filter is given" do
        let(:country) { FactoryBot.create(:country) }
        let(:options) { {country_id: country.id} }

        before do
          @show = FactoryBot.create(:show, country:)
          FactoryBot.create(:show)
        end

        it "only returns shows for that country" do
          expect(subject).to eq [@show]
        end
      end

      context "when genre filters are given" do
        let(:action) { FactoryBot.create(:genre, name: "Action") }
        let(:animation) { FactoryBot.create(:genre, name: "Animation") }
        let(:horror) { FactoryBot.create(:genre, name: "Horror") }
        let(:comedy) { FactoryBot.create(:genre, name: "Comedy") }
        let(:options) { {genre_ids: [action.id, horror.id]} }

        before do
          @show = FactoryBot.create(:show, genres: [horror, comedy, action])
          FactoryBot.create(:show, genres: [action])
          FactoryBot.create(:show, genres: [animation, horror])
        end

        it "returns only the shows that include all given genres" do
          expect(subject).to eq [@show]
        end
      end

      context "when filtering by premiere dates" do
        let(:options) { {premiere_date_from: "2025-01-01", premiere_date_to: "2025-01-02"} }

        before do
          @show1 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-01")
          @show2 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-02")
          FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-03")
        end

        it "only returns shows within the premiere date" do
          expect(subject.length).to eq 2
          expect(subject).to include(@show1)
          expect(subject).to include(@show2)
        end
      end

      context "when filtering by episode air dates" do
        let(:options) { {episode_air_date_from: "2025-01-01", episode_air_date_to: "2025-01-02"} }

        before do
          @show1 = FactoryBot.create(:show)
          season = FactoryBot.create(:season, show: @show1)
          FactoryBot.create(:episode, season:, number: 1, original_air_date: "2025-01-01")

          @show2 = FactoryBot.create(:show)
          season = FactoryBot.create(:season, show: @show2)
          FactoryBot.create(:episode, season:, number: 1, original_air_date: "2025-01-02")

          @show3 = FactoryBot.create(:show)
          season = @show3.seasons.first # Special season, not counted
          FactoryBot.create(:episode, season:, number: 1, original_air_date: "2025-01-02")

          @show4 = FactoryBot.create(:show)
          season = FactoryBot.create(:season, show: @show4)
          FactoryBot.create(:episode, season:, number: 1, original_air_date: "2025-01-03") # Outside of range

          FactoryBot.create(:show) # No episodes
        end

        it "only returns shows that have an episode that aired within the dates given" do
          expect(subject.length).to eq 2
          expect(subject).to include(@show1)
          expect(subject).to include(@show2)
        end
      end

      context "when company filters are given" do
        let(:disney) { FactoryBot.create(:company, name: "Disney") }
        let(:cartoon_network) { FactoryBot.create(:company, name: "Cartoon Network") }
        let(:youtube) { FactoryBot.create(:company, name: "YouTube") }
        let(:nicktoons) { FactoryBot.create(:company, name: "Nicktoons") }
        let(:options) { {company_ids: [disney.id, youtube.id]} }

        before do
          @show = FactoryBot.create(:show, companies: [youtube, nicktoons, disney])
          FactoryBot.create(:show, companies: [disney])
          FactoryBot.create(:show, companies: [cartoon_network, youtube])
        end

        it "returns only the shows that include all given companies" do
          expect(subject).to eq [@show]
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
          @show = FactoryBot.create(:show)
          [uk_18, uk_r, uk_pg].each do |certification|
            FactoryBot.create(:content_rating, show: @show, certification:)
          end
          @show2 = FactoryBot.create(:show)
          FactoryBot.create(:content_rating, show: @show2, certification: uk_pg)
          @show3 = FactoryBot.create(:show)
          [uk_nr, uk_18].each do |certification|
            FactoryBot.create(:content_rating, show: @show3, certification:)
          end
          @show4 = FactoryBot.create(:show)
          FactoryBot.create(:content_rating, show: @show4, certification: uk_nr)
        end

        it "returns any show that include any of the given certifications" do
          expect(subject.count).to eq 3
          expect(subject).to include(@show)
          expect(subject).to include(@show2)
          expect(subject).to include(@show3)
        end
      end

      context "when keyword filters are given" do
        let(:options) { {keywords: ["nonsense", "nope"]} }

        before do
          @show1 = FactoryBot.create(:show, keyword_list: ["nonsense", "nope"])
          @show2 = FactoryBot.create(:show, keyword_list: ["nope"])
          @show3 = FactoryBot.create(:show)
        end

        it "only returns shows with the keywords" do
          expect(subject).to eq [@show1]
        end

        context "when there is a blank string" do
          let(:options) { {keywords: [""]} }

          it "treats it as a nil value" do
            expect(subject.count).to eq 3
            expect(subject).to include(@show1)
            expect(subject).to include(@show2)
            expect(subject).to include(@show3)
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
            premiere_date_from: "2025-01-01",
            premiere_date_to: "2025-01-02",
            sort: "premiere_date"
          }
        }

        before do
          @show1 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-02", genres: [horror, comedy, action])
          @show2 = FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-01", genres: [horror, comedy, action])
          FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-03", genres: [action])
          FactoryBot.create(:show, :with_premiere_date, date_for_premiere: "2025-01-01", genres: [animation, horror])
        end

        it "applies the filter and sorting" do
          expect(subject).to eq [@show2, @show1]
        end
      end

      context "when there are no filters" do
        let(:action) { FactoryBot.create(:genre, name: "Action") }
        let(:animation) { FactoryBot.create(:genre, name: "Animation") }
        let(:horror) { FactoryBot.create(:genre, name: "Horror") }
        let(:comedy) { FactoryBot.create(:genre, name: "Comedy") }
        let(:options) { {} }

        before do
          @show1 = FactoryBot.create(:show)
          @show2 = FactoryBot.create(:show)
          @show3 = FactoryBot.create(:show)
        end

        it "returns all movies" do
          expect(subject.length).to eq 3
          expect(subject).to include(@show1)
          expect(subject).to include(@show2)
          expect(subject).to include(@show3)
        end
      end
    end

    describe "#to_params" do
      let(:instance) { Shows.new(options) }
      let(:options) {
        {
          country_id:,
          genre_ids:,
          company_ids:,
          premiere_date_from:,
          premiere_date_to:,
          episode_air_date_from:,
          episode_air_date_to:,
          certification_ids:,
          keywords:,
          sort:
        }
      }
      let(:country_id) { 1 }
      let(:genre_ids) { [1] }
      let(:company_ids) { [1] }
      let(:premiere_date_from) { "2025-01-01" }
      let(:premiere_date_to) { "2025-01-02" }
      let(:episode_air_date_from) { "2025-01-01" }
      let(:episode_air_date_to) { "2025-01-02" }
      let(:certification_ids) { [1] }
      let(:keywords) { ["lol"] }
      let(:sort) { "translated_title" }

      subject { instance.to_params }

      it "converts the options to params" do
        expect(subject).to eq({
          country_id:,
          genre_ids:,
          company_ids:,
          premiere_date_from:,
          premiere_date_to:,
          episode_air_date_from:,
          episode_air_date_to:,
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
            company_ids:,
            premiere_date_from:,
            premiere_date_to:,
            episode_air_date_from:,
            episode_air_date_to:,
            certification_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when genre ids are not present" do
        let(:genre_ids) { [] }

        it "does not include the genre ids" do
          expect(subject).to eq({
            country_id:,
            company_ids:,
            premiere_date_from:,
            premiere_date_to:,
            episode_air_date_from:,
            episode_air_date_to:,
            certification_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when premiere date from is not present" do
        let(:premiere_date_from) { nil }

        it "does not include the premiere date from" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            company_ids:,
            premiere_date_to:,
            episode_air_date_from:,
            episode_air_date_to:,
            certification_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when premiere date to is not present" do
        let(:premiere_date_to) { nil }

        it "does not include the country id" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            company_ids:,
            premiere_date_from:,
            episode_air_date_from:,
            episode_air_date_to:,
            certification_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when episode air date from is not present" do
        let(:episode_air_date_from) { nil }

        it "does not include the premiere date from" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            company_ids:,
            premiere_date_from:,
            premiere_date_to:,
            episode_air_date_to:,
            certification_ids:,
            keywords:,
            sort:
          })
        end
      end

      context "when episode air date to is not present" do
        let(:episode_air_date_to) { nil }

        it "does not include the premiere date from" do
          expect(subject).to eq({
            country_id:,
            genre_ids:,
            company_ids:,
            premiere_date_from:,
            premiere_date_to:,
            episode_air_date_from:,
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
            premiere_date_from:,
            premiere_date_to:,
            episode_air_date_from:,
            episode_air_date_to:,
            certification_ids:,
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
            company_ids:,
            premiere_date_from:,
            premiere_date_to:,
            episode_air_date_from:,
            episode_air_date_to:,
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
            company_ids:,
            premiere_date_from:,
            premiere_date_to:,
            episode_air_date_from:,
            episode_air_date_to:,
            certification_ids:,
            keywords:,
            sort: "translated_title"
          })
        end
      end
    end

    describe "#sorting_options" do
      subject { Shows.new({}).sorting_options }

      it "returns an array of valid sorting options" do
        expect(subject).to eq([
          {name: "Title", value: "translated_title"},
          {name: "Premiere Date", value: "premiere_date"},
          {name: "Popularity", value: "popularity"},
          {name: "Rating", value: "rating"}
        ])
      end
    end
  end
end
