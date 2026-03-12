require "rails_helper"

RSpec.describe Credits do
  let(:credits) { Credits.new(person) }
  let(:person) { FactoryBot.create(:person) }

  describe "#as_cast_member" do
    it "orders by the year" do
      movie1 = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
      movie2 = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2022, 1, 1))
      FactoryBot.create(:cast_member, person:, record: movie1, character: "Bob")
      FactoryBot.create(:cast_member, person:, record: movie2, character: "Charles")
      expect(credits.as_cast_member).to eq([
        {year: 2022, credits: {movie2 => {"Charles" => 1}}},
        {year: 2021, credits: {movie1 => {"Bob" => 1}}}
      ])
    end

    context "when there is a record with no year" do
      it "orders the records with no year to the top" do
        movie1 = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        movie2 = FactoryBot.create(:movie)
        FactoryBot.create(:cast_member, person:, record: movie1, character: "Bob")
        FactoryBot.create(:cast_member, person:, record: movie2, character: "Charles")
        expect(credits.as_cast_member).to eq([
          {year: nil, credits: {movie2 => {"Charles" => 1}}},
          {year: 2021, credits: {movie1 => {"Bob" => 1}}}
        ])
      end
    end

    context "when there are multiple credits for the same character (e.g. multiple guest stars)" do
      it "counts the amount of credits they have for that character" do
        movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        show = FactoryBot.create(:show)
        episode1 = FactoryBot.create(:episode, number: 1, season: show.seasons.first, original_air_date: Date.new(2021, 1, 1))
        episode2 = FactoryBot.create(:episode, number: 2, season: show.seasons.first, original_air_date: Date.new(2021, 1, 1))
        episode3 = FactoryBot.create(:episode, original_air_date: Date.new(2021, 1, 1))
        FactoryBot.create(:cast_member, person:, record: movie, character: "Bob") # Same character name + year, but not for the same parent record
        FactoryBot.create(:cast_member, person:, record: episode1, character: "Bob")
        FactoryBot.create(:cast_member, person:, record: episode2, character: "Bob")
        FactoryBot.create(:cast_member, person:, record: episode3, character: "Bob") # Same character name + year, but not for the same parent record
        expect(credits.as_cast_member).to eq([
          {
            year: 2021,
            credits: {
              movie => {"Bob" => 1},
              show => {"Bob" => 2},
              episode3.show => {"Bob" => 1}
            }
          }
        ])
      end
    end

    context "when a record is an episode" do
      it "groups by the episodes show" do
        show = FactoryBot.create(:show)
        episode = FactoryBot.create(:episode, number: 1, season: show.seasons.first, original_air_date: Date.new(2021, 1, 1))
        FactoryBot.create(:cast_member, person:, record: episode, character: "Bob")
        expect(credits.as_cast_member).to eq([
          {
            year: 2021,
            credits: {
              show => {"Bob" => 1}
            }
          }
        ])
      end

      context "when the episode has no year" do
        context "when the episode's season has no year" do
          it "groups with a nil year" do
            show = FactoryBot.create(:show)
            season = show.seasons.first
            episode = FactoryBot.create(:episode, number: 1, season:, original_air_date: nil)
            FactoryBot.create(:cast_member, person:, record: episode, character: "Bob")
            expect(credits.as_cast_member).to eq([
              {
                year: nil,
                credits: {
                  show => {"Bob" => 1}
                }
              }
            ])
          end
        end

        context "when the episode's season has a year" do
          it "groups the episode into the season's year" do
            show = FactoryBot.create(:show)
            season = show.seasons.first
            FactoryBot.create(:episode, number: 1, season:, original_air_date: Date.new(2021, 1, 1)) # First episode of the season applies premiere date to the season
            episode = FactoryBot.create(:episode, number: 2, season:, original_air_date: nil)
            FactoryBot.create(:cast_member, person:, record: episode, character: "Bob")
            expect(credits.as_cast_member).to eq([
              {
                year: 2021,
                credits: {
                  show => {"Bob" => 1}
                }
              }
            ])
          end
        end
      end
    end

    context "when a record is a season" do
      it "groups by the seasons show with the episode count for the year" do
        show = FactoryBot.create(:show)
        season = show.seasons.first
        FactoryBot.create(:episode, number: 1, season:, original_air_date: nil)
        FactoryBot.create(:episode, number: 2, season:, original_air_date: nil)
        FactoryBot.create(:cast_member, person:, record: season, character: "Bob")
        expect(credits.as_cast_member).to eq([
          {
            year: nil,
            credits: {
              show => {"Bob" => 2}
            }
          }
        ])
      end

      context "when the season spans multiple years" do
        it "groups all episode counts into the seasons year regardless of episode air dates" do
          show = FactoryBot.create(:show)
          season = show.seasons.first
          FactoryBot.create(:episode, number: 1, season:, original_air_date: Date.new(2021, 1, 1))
          FactoryBot.create(:episode, number: 2, season:, original_air_date: Date.new(2022, 1, 1))
          FactoryBot.create(:cast_member, person:, record: season, character: "Bob")
          expect(credits.as_cast_member).to eq([
            {
              year: 2021,
              credits: {
                show => {"Bob" => 2}
              }
            }
          ])
        end
      end
    end

    context "when a record is a show" do
      it "groups to itself the the amount of episodes in the count" do
        show = FactoryBot.create(:show)
        season = show.seasons.first
        FactoryBot.create(:episode, number: 1, season:, original_air_date: nil)
        FactoryBot.create(:episode, number: 2, season:, original_air_date: nil)
        FactoryBot.create(:cast_member, person:, record: show, character: "Bob")
        expect(credits.as_cast_member).to eq([
          {
            year: nil,
            credits: {
              show => {"Bob" => 2}
            }
          }
        ])
      end

      context "when the show spans multiple years" do
        it "groups all episode counts into the show's year regardless of episode air dates" do
          show = FactoryBot.create(:show)
          season = FactoryBot.create(:season, show:, number: 1)
          FactoryBot.create(:episode, number: 1, season:, original_air_date: Date.new(2021, 1, 1))
          FactoryBot.create(:episode, number: 2, season:, original_air_date: Date.new(2022, 1, 1))
          FactoryBot.create(:cast_member, person:, record: show, character: "Bob")
          expect(credits.as_cast_member).to eq([
            {
              year: 2021,
              credits: {
                show => {"Bob" => 2}
              }
            }
          ])
        end
      end
    end

    context "when a record is a movie" do
      it "groups to itself" do
        movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        FactoryBot.create(:cast_member, person:, record: movie, character: "Bob")
        expect(credits.as_cast_member).to eq([
          {year: 2021, credits: {movie => {"Bob" => 1}}}
        ])
      end
    end
  end

  describe "#as_crew_member" do
    it "orders by the year" do
      movie1 = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
      movie2 = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2022, 1, 1))
      FactoryBot.create(:crew_member, person:, record: movie1, job: FactoryBot.build(:job, name: "Job 1"))
      FactoryBot.create(:crew_member, person:, record: movie2, job: FactoryBot.build(:job, name: "Job 2"))
      expect(credits.as_crew_member).to eq([
        {year: 2022, credits: {movie2 => {"Job 2" => 1}}},
        {year: 2021, credits: {movie1 => {"Job 1" => 1}}}
      ])
    end

    context "when there is a record with no year" do
      it "orders the records with no year to the top" do
        movie1 = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        movie2 = FactoryBot.create(:movie)
        FactoryBot.create(:crew_member, person:, record: movie1, job: FactoryBot.build(:job, name: "Job 1"))
        FactoryBot.create(:crew_member, person:, record: movie2, job: FactoryBot.build(:job, name: "Job 2"))
        expect(credits.as_crew_member).to eq([
          {year: nil, credits: {movie2 => {"Job 2" => 1}}},
          {year: 2021, credits: {movie1 => {"Job 1" => 1}}}
        ])
      end
    end

    context "when there are multiple credits for the same job (e.g. multiple credits across episodes)" do
      it "counts the amount of credits they have for that job" do
        movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        show = FactoryBot.create(:show)
        episode1 = FactoryBot.create(:episode, number: 1, season: show.seasons.first, original_air_date: Date.new(2021, 1, 1))
        episode2 = FactoryBot.create(:episode, number: 2, season: show.seasons.first, original_air_date: Date.new(2021, 1, 1))
        episode3 = FactoryBot.create(:episode, original_air_date: Date.new(2021, 1, 1))
        job = FactoryBot.create(:job, name: "Job 1")
        FactoryBot.create(:crew_member, person:, record: movie, job:) # Same character name + year, but not for the same parent record
        FactoryBot.create(:crew_member, person:, record: episode1, job:)
        FactoryBot.create(:crew_member, person:, record: episode2, job:)
        FactoryBot.create(:crew_member, person:, record: episode3, job:)
        expect(credits.as_crew_member).to eq([
          {
            year: 2021,
            credits: {
              movie => {"Job 1" => 1},
              show => {"Job 1" => 2},
              episode3.show => {"Job 1" => 1}
            }
          }
        ])
      end
    end

    context "when a record is an episode" do
      it "groups by the episodes show" do
        show = FactoryBot.create(:show)
        episode = FactoryBot.create(:episode, number: 1, season: show.seasons.first, original_air_date: Date.new(2021, 1, 1))
        FactoryBot.create(:crew_member, person:, record: episode, job: FactoryBot.build(:job, name: "Job 1"))
        expect(credits.as_crew_member).to eq([
          {
            year: 2021,
            credits: {
              show => {"Job 1" => 1}
            }
          }
        ])
      end

      context "when the episode has no year" do
        context "when the episode's season has no year" do
          it "groups with a nil year" do
            show = FactoryBot.create(:show)
            season = show.seasons.first
            episode = FactoryBot.create(:episode, number: 1, season:, original_air_date: nil)
            FactoryBot.create(:crew_member, person:, record: episode, job: FactoryBot.build(:job, name: "Job 1"))
            expect(credits.as_crew_member).to eq([
              {
                year: nil,
                credits: {
                  show => {"Job 1" => 1}
                }
              }
            ])
          end
        end

        context "when the episode's season has a year" do
          it "groups the episode into the season's year" do
            show = FactoryBot.create(:show)
            season = show.seasons.first
            FactoryBot.create(:episode, number: 1, season:, original_air_date: Date.new(2021, 1, 1)) # First episode of the season applies premiere date to the season
            episode = FactoryBot.create(:episode, number: 2, season:, original_air_date: nil)
            FactoryBot.create(:crew_member, person:, record: episode, job: FactoryBot.build(:job, name: "Job 1"))
            expect(credits.as_crew_member).to eq([
              {
                year: 2021,
                credits: {
                  show => {"Job 1" => 1}
                }
              }
            ])
          end
        end
      end
    end

    context "when a record is a show" do
      it "groups to itself the the amount of episodes in the count" do
        show = FactoryBot.create(:show)
        season = show.seasons.first
        FactoryBot.create(:episode, number: 1, season:, original_air_date: nil)
        FactoryBot.create(:episode, number: 2, season:, original_air_date: nil)
        FactoryBot.create(:crew_member, person:, record: show, job: FactoryBot.build(:job, name: "Job 1"))
        expect(credits.as_crew_member).to eq([
          {
            year: nil,
            credits: {
              show => {"Job 1" => 2}
            }
          }
        ])
      end

      context "when the show spans multiple years" do
        it "groups all episode counts into the show's year regardless of episode air dates" do
          show = FactoryBot.create(:show)
          season = FactoryBot.create(:season, show:, number: 1)
          FactoryBot.create(:episode, number: 1, season:, original_air_date: Date.new(2021, 1, 1))
          FactoryBot.create(:episode, number: 2, season:, original_air_date: Date.new(2022, 1, 1))
          FactoryBot.create(:crew_member, person:, record: show, job: FactoryBot.build(:job, name: "Job 1"))
          expect(credits.as_crew_member).to eq([
            {
              year: 2021,
              credits: {
                show => {"Job 1" => 2}
              }
            }
          ])
        end
      end
    end

    context "when a record is a movie" do
      it "groups to itself" do
        movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        FactoryBot.create(:crew_member, person:, record: movie, job: FactoryBot.build(:job, name: "Job 1"))
        expect(credits.as_crew_member).to eq([
          {year: 2021, credits: {movie => {"Job 1" => 1}}}
        ])
      end
    end
  end

  describe "#credit_types" do
    subject { credits.credit_types }

    context "when there are no cast credits for the person" do
      before do
        movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        FactoryBot.create(:crew_member, person:, record: movie, job: FactoryBot.build(:job, name: "Job 1"))
      end

      it { should eq ["crew"] }
    end

    context "when there are no crew credits for the person" do
      before do
        movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        FactoryBot.create(:cast_member, person:, record: movie, character: "Bob")
      end

      it { should eq ["cast"] }
    end

    context "when there are both cast and crew credits for the person" do
      before do
        movie = FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2021, 1, 1))
        FactoryBot.create(:cast_member, person:, record: movie, character: "Bob")
        FactoryBot.create(:crew_member, person:, record: movie, job: FactoryBot.build(:job, name: "Job 1"))
      end

      it { should eq ["cast", "crew"] }
    end

    context "when the person has no credits" do
      it { should be_empty }
    end
  end
end
