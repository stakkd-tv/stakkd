require "rails_helper"
require_relative "shared_examples/slugify"
require_relative "shared_examples/has_imdb"
require_relative "shared_examples/has_galleries"

RSpec.describe Show, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
    it { should belong_to(:language) }
    it { should have_many(:alternative_names).dependent(:destroy) }
    it { should have_many(:season_regulars).class_name("CastMember").dependent(:destroy) }
    it { should have_many(:crew_members).dependent(:destroy) }
    it { should have_many(:content_ratings).dependent(:destroy) }
    it { should have_many(:genre_assignments).dependent(:destroy) }
    it { should have_many(:genres).through(:genre_assignments) }
    it { should have_many(:keyword_taggings).dependent(:destroy) }
    it { should have_many(:company_assignments).dependent(:destroy) }
    it { should have_many(:companies).through(:company_assignments) }
    it { should have_many(:taglines).dependent(:destroy) }
    it { should have_many(:seasons).dependent(:destroy) }
    it { should have_many(:ordered_seasons).class_name("Season") }
    it { should have_many(:seasons_without_specials).class_name("Season") }
    it { should have_many(:non_special_episodes).through(:seasons_without_specials) }
    it { should have_many(:episodes).through(:seasons) }
  end

  describe "validations" do
    it { should validate_presence_of(:translated_title) }
    it { should validate_presence_of(:original_title) }
    it { should validate_inclusion_of(:status).in_array(Show::STATUSES) }
    it { should validate_inclusion_of(:type).in_array(Show::TYPES) }
  end

  describe "callbacks" do
    describe "after_create :create_specials_season" do
      it "creates a new season related to the show with a season number of 0" do
        show = FactoryBot.build(:show)
        show.save!
        expect(show.seasons.count).to eq 1
        season = show.seasons.first
        expect(season.number).to eq 0
        expect(season.translated_name).to eq "Specials"
        expect(season.original_name).to eq "Specials"
      end
    end
  end

  it_behaves_like "a slugified model", :show, :translated_title

  describe ".inheritance_column" do
    it "should be empty" do
      expect(Show.inheritance_column).to be_nil
    end
  end

  it_behaves_like "a model with galleries", :show, [:posters, :backgrounds, :logos, :videos]

  it_behaves_like "a model with imdb_id", Show

  describe "#slug=" do
    it "sets the title_kebab" do
      show = Show.new
      show.slug = "test"
      expect(show.title_kebab).to eq "test"
    end
  end

  describe "#to_s" do
    it "returns the translated title" do
      expect(Show.new(translated_title: "Test name").to_s).to eq "Test name"
    end
  end

  describe "#tagline" do
    it "returns the first tagline ordered by position" do
      show = FactoryBot.create(:show)
      FactoryBot.create(:tagline, record: show, tagline: "Tagline 1")
      tagline2 = FactoryBot.create(:tagline, record: show, tagline: "Tagline 2")
      tagline2.insert_at(1)
      expect(show.tagline).to eq "Tagline 2"
    end

    it "returns nil when there are no taglines" do
      show = FactoryBot.create(:show)
      expect(show.tagline).to be_nil
    end
  end

  describe "#runtime" do
    it "calculates the runtime excluding special episodes" do
      show = FactoryBot.create(:show)
      season = FactoryBot.create(:season, show: show)
      FactoryBot.create(:episode, number: 1, season: season, runtime: 40)
      FactoryBot.create(:episode, number: 2, season: season, runtime: 20)
      FactoryBot.create(:episode, season: show.ordered_seasons.first, runtime: 30)
      expect(show.runtime).to eq 60
    end
  end

  describe "#cast_members" do
    it "returns season regulars" do
      show = FactoryBot.create(:show)
      regulars = [FactoryBot.create(:cast_member, record: show)]
      expect(show.cast_members).to eq regulars
    end
  end

  describe "#creators" do
    context "when the show has a creator" do
      it "returns the creator" do
        creator = FactoryBot.build(:crew_member, job: FactoryBot.build(:job, name: Job::CREATOR))
        show = FactoryBot.create(:show, crew_members: [creator])
        expect(show.creators).to eq [creator]
      end
    end

    context "when the show does not have a creator" do
      it "returns an empty array" do
        show = FactoryBot.create(:show)
        expect(show.creators).to eq []
      end
    end
  end

  describe "#year" do
    it "returns the year of the premiere date" do
      show = FactoryBot.create(:show)
      season = FactoryBot.create(:season, number: 1, show:)
      episode = FactoryBot.create(:episode, season:, original_air_date: Date.today)
      expect(show.year).to eq episode.original_air_date.year
    end

    it "returns nil when there is no premiere date" do
      show = FactoryBot.create(:show)
      expect(show.year).to be_nil
    end
  end

  describe "#latest_season_number" do
    it "returns the latest season number" do
      show = FactoryBot.create(:show)
      FactoryBot.create(:season, number: 2, show:)
      expect(show.latest_season_number).to eq 2
    end

    it "returns 0 when there are no seasons" do
      show = FactoryBot.create(:show)
      show.seasons.destroy_all
      expect(show.reload.latest_season_number).to eq 0
    end
  end
end
