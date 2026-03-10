require "rails_helper"

RSpec.describe Season, type: :model do
  describe "associations" do
    it { should belong_to(:show) }
    it { should have_many(:season_regulars).class_name("CastMember").dependent(:destroy) }
    it { should have_many(:videos).dependent(:destroy) }
    it { should have_many(:episodes).dependent(:destroy) }
    it { should have_many(:ordered_episodes) }
    it { should have_many_attached(:posters) }
  end

  describe "validations" do
    subject { FactoryBot.create(:season) }
    it { should validate_presence_of(:translated_name) }
    it { should validate_presence_of(:original_name) }
    it { should validate_uniqueness_of(:number).scoped_to([:show_id]) }
    it { should validate_numericality_of(:number).is_greater_than_or_equal_to(0) }
  end

  describe ".without_specials" do
    it "returns all seasons excluding special seasons" do
      season1 = FactoryBot.create(:season, number: 1)
      show_with_special = FactoryBot.create(:show)
      special = show_with_special.seasons.first
      expect(special).to be
      expect(special.number).to eq 0
      expect(Season.without_specials).to include(season1)
      expect(Season.without_specials).not_to include(special)
    end
  end

  describe ".ordered" do
    it "returns the seasons in order of number" do
      show = FactoryBot.create(:show)
      season2 = FactoryBot.create(:season, number: 2, show:)
      season1 = FactoryBot.create(:season, number: 1, show:)
      special = show.seasons.where(number: 0).first
      expect(Season.ordered).to eq [special, season1, season2]
    end
  end

  describe ".nested" do
    it "returns the seasons with the number" do
      season1 = FactoryBot.create(:season, number: 1)
      FactoryBot.create(:season, number: 2)
      expect(Season.nested(1)).to eq [season1]
    end
  end

  describe "#poster" do
    context "when there are no posters" do
      it "returns the 2:3 asset" do
        season = Season.new
        expect(season.poster).to eq "2:3.png"
      end
    end

    context "when there are posters" do
      it "returns an image" do
        season = FactoryBot.create(
          :season,
          posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(season.poster).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#available_galleries" do
    it "returns the galleries available" do
      expect(Season.new.available_galleries).to eq [:posters, :videos]
    end
  end

  describe "#to_param" do
    it "returns the season number as a string" do
      expect(Season.new(number: 2).to_param).to eq "2"
    end
  end

  describe "#specials?" do
    context "when season number is 0" do
      it "returns true" do
        special = Season.new(number: 0)
        expect(special.specials?).to be true
      end
    end

    context "when the season number is not 0" do
      it "returns false" do
        season = Season.new(number: 1)
        expect(season.specials?).to be false
      end
    end
  end

  describe "#related_records" do
    it "includes the show in the hash" do
      season = FactoryBot.create(:season)
      expect(season.related_records).to eq({show: season.show, season:})
    end
  end

  describe "#records_for_polymorphic_paths" do
    it "includes the show in the array ordered by depth" do
      season = FactoryBot.create(:season)
      expect(season.records_for_polymorphic_paths).to eq([season.show, season])
    end
  end

  describe "#to_s" do
    it "returns the season number as a string" do
      expect(Season.new(number: 2, show: Show.new(translated_title: "Testing")).to_s).to eq "Testing - Season 2"
    end
  end

  describe "#runtime" do
    it "returns the sum of all episodes" do
      season = FactoryBot.create(:season)
      FactoryBot.create(:episode, number: 1, season:, runtime: 20)
      FactoryBot.create(:episode, number: 2, season:, runtime: 20)
      expect(season.runtime).to eq 40
    end

    it "returns 0 when no episodes" do
      season = FactoryBot.create(:season)
      expect(season.runtime).to eq 0
    end
  end

  describe "#next_season" do
    it "returns the next season" do
      season = FactoryBot.create(:season)
      next_season = FactoryBot.create(:season, number: season.number + 1, show: season.show)
      expect(season.next_season).to eq next_season
    end

    it "returns nil when there is no next season" do
      show = FactoryBot.create(:show)
      season = show.seasons.first
      expect(season.next_season).to be_nil
    end
  end

  describe "#previous_season" do
    it "returns the previous season" do
      show = FactoryBot.create(:show)
      special = show.seasons.first
      season = FactoryBot.create(:season, number: 1, show: show)
      expect(season.previous_season).to eq special
    end

    it "returns nil when there is no previous season" do
      show = FactoryBot.create(:show)
      season = show.seasons.first
      expect(season.previous_season).to be_nil
    end
  end
end
