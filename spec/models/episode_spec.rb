require "rails_helper"
require_relative "shared_examples/has_imdb"

RSpec.describe Episode, type: :model do
  describe "associations" do
    it { should belong_to(:season) }
    it { should have_many(:guest_stars).class_name("CastMember") }
    it { should have_many(:crew_members).dependent(:destroy) }
    it { should have_many(:videos).dependent(:destroy) }
    it { should have_one(:show).through(:season) }
    it { should have_many_attached(:backgrounds) }
  end

  describe "validations" do
    subject { FactoryBot.create(:episode) }
    it { should validate_presence_of(:translated_name) }
    it { should validate_presence_of(:original_name) }
    it { should validate_uniqueness_of(:number).scoped_to([:season_id]) }
    it { should validate_numericality_of(:number).is_greater_than_or_equal_to(1) }
    it { should validate_inclusion_of(:episode_type).in_array(Episode::TYPES) }
    it { should validate_numericality_of(:runtime).is_greater_than_or_equal_to(0) }
  end

  describe "after_save :set_season_premiere_date" do
    context "when episode is the first episode in the season" do
      it "sets the seasons premiere date" do
        show = FactoryBot.create(:show)
        specials = show.seasons.first
        expect(specials.premiere_date).to be_nil
        episode = FactoryBot.create(:episode, season: specials, original_air_date: Date.today)
        expect(specials.premiere_date).to eq episode.original_air_date
      end
    end

    context "when episode is not the first episode in the season" do
      it "does not set the seasons premiere date" do
        show = FactoryBot.create(:show)
        specials = show.seasons.first
        expect(specials.premiere_date).to be_nil
        episode = FactoryBot.create(:episode, number: 1, season: specials, original_air_date: Date.today)
        expect(specials.premiere_date).to eq episode.original_air_date
        FactoryBot.create(:episode, number: 2, season: specials, original_air_date: Date.tomorrow)
        expect(specials.premiere_date).to eq episode.original_air_date
      end
    end
  end

  describe ".ordered" do
    it "returns the seasons in order of number" do
      episode2 = FactoryBot.create(:episode, number: 2)
      episode1 = FactoryBot.create(:episode, number: 1)
      expect(Episode.ordered).to eq [episode1, episode2]
    end
  end

  describe ".nested" do
    it "returns the episodes with the number" do
      episode1 = FactoryBot.create(:episode, number: 1)
      FactoryBot.create(:episode, number: 2)
      expect(Episode.nested(1)).to eq [episode1]
    end
  end

  it_behaves_like "a model with imdb_id", Episode

  describe "#background" do
    context "when there are no backgrounds" do
      it "returns the 16:9 asset" do
        episode = Episode.new
        expect(episode.background).to eq "16:9.png"
      end
    end

    context "when there are backgrounds" do
      it "returns an image" do
        episode = FactoryBot.create(
          :episode,
          backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(episode.background).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#to_param" do
    it "returns the episode number as a string" do
      expect(Episode.new(number: 2).to_param).to eq "2"
    end
  end

  describe "#next_episode" do
    it "returns the next episode" do
      season = FactoryBot.create(:season)
      episode = FactoryBot.create(:episode, season: season, number: 1)
      next_episode = FactoryBot.create(:episode, season: season, number: 2)
      expect(episode.next_episode).to eq next_episode
    end

    it "returns nil when there is no next episode" do
      season = FactoryBot.create(:season)
      episode = FactoryBot.create(:episode, season: season, number: 1)
      expect(episode.next_episode).to be_nil
    end
  end

  describe "#previous_episode" do
    it "returns the previous episode" do
      season = FactoryBot.create(:season)
      episode = FactoryBot.create(:episode, season: season, number: 2)
      previous_episode = FactoryBot.create(:episode, season: season, number: 1)
      expect(episode.previous_episode).to eq previous_episode
    end

    it "returns nil when there is no previous episode" do
      season = FactoryBot.create(:season)
      episode = FactoryBot.create(:episode, season: season, number: 1)
      expect(episode.previous_episode).to be_nil
    end
  end

  describe "#related_records" do
    it "includes the show and season in the hash" do
      episode = FactoryBot.create(:episode)
      expect(episode.related_records).to eq({show: episode.show, season: episode.season, episode:})
    end
  end

  describe "#records_for_polymorphic_paths" do
    it "includes the show and season in the array ordered by depth" do
      episode = FactoryBot.create(:episode)
      expect(episode.records_for_polymorphic_paths).to eq([episode.show, episode.season, episode])
    end
  end

  describe "#directors" do
    context "when the episode has a director" do
      it "returns the directors" do
        director = FactoryBot.build(:crew_member, job: FactoryBot.build(:job, name: Job::DIRECTOR))
        episode = FactoryBot.create(:episode, crew_members: [director])
        expect(episode.directors).to eq [director]
      end
    end

    context "when the episode does not have a director" do
      it "returns an empty array" do
        episode = FactoryBot.create(:episode)
        expect(episode.directors).to eq []
      end
    end
  end

  describe "#writers" do
    context "when the episode has a writer" do
      it "returns the writers" do
        writer = FactoryBot.build(:crew_member, job: FactoryBot.build(:job, name: Job::WRITER))
        episode = FactoryBot.create(:episode, crew_members: [writer])
        expect(episode.writers).to eq [writer]
      end
    end

    context "when the episode does not have a writer" do
      it "returns an empty array" do
        episode = FactoryBot.create(:episode)
        expect(episode.writers).to eq []
      end
    end
  end

  describe "#year" do
    it "returns the year of the release date" do
      episode = FactoryBot.create(:episode, original_air_date: Date.new(2022, 1, 1))
      expect(episode.year).to eq 2022
    end

    it "returns nil when the release date is nil" do
      episode = FactoryBot.create(:episode, original_air_date: nil)
      expect(episode.year).to be_nil
    end
  end

  Episode::TYPES.each do |type|
    describe "##{type}?" do
      it "returns true when the episode type matches" do
        episode = Episode.new(episode_type: type)
        expect(episode.send("#{type}?")).to be_truthy
      end

      it "returns false when the episode type does not match" do
        episode = Episode.new(episode_type: Episode::TYPES.reject { |t| t == type }.sample)
        expect(episode.send("#{type}?")).to be_falsey
      end
    end
  end
end
