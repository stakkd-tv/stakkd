require "rails_helper"
require_relative "shared_examples/slugify"

RSpec.describe Show, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
    it { should belong_to(:language) }
    it { should have_many(:alternative_names).dependent(:destroy) }
    it { should have_many(:content_ratings).dependent(:destroy) }
    it { should have_many(:genre_assignments).dependent(:destroy) }
    it { should have_many(:genres).through(:genre_assignments) }
    it { should have_many(:keyword_taggings).dependent(:destroy) }
    it { should have_many(:company_assignments).dependent(:destroy) }
    it { should have_many(:companies).through(:company_assignments) }
    it { should have_many(:taglines).dependent(:destroy) }
    it { should have_many(:videos).dependent(:destroy) }
    it { should have_many(:seasons).dependent(:destroy) }
    it { should have_many_attached(:posters) }
    it { should have_many_attached(:backgrounds) }
    it { should have_many_attached(:logos) }
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

  describe "#poster" do
    context "when there are no posters" do
      it "returns the 2:3 asset" do
        show = Show.new
        expect(show.poster).to eq "2:3.png"
      end
    end

    context "when there are posters" do
      it "returns an image" do
        show = FactoryBot.create(
          :show,
          posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(show.poster).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#background" do
    context "when there are no backgrounds" do
      it "returns nil" do
        show = Show.new
        expect(show.background).to be_nil
      end
    end

    context "when there are backgrounds" do
      it "returns an image" do
        show = FactoryBot.create(
          :show,
          backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(show.background).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#logo" do
    context "when there are no logos" do
      it "returns the 1:1 asset" do
        show = Show.new
        expect(show.logo).to eq "1:1.png"
      end
    end

    context "when there are logos" do
      it "returns an image" do
        show = FactoryBot.create(
          :show,
          logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(show.logo).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#imdb_url" do
    it "returns the link to imdb" do
      show = Show.new(imdb_id: "tt0000000")
      expect(show.imdb_url).to eq "https://www.imdb.com/title/tt0000000/"
    end
  end

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

  describe "#available_galleries" do
    it "returns the available galleries" do
      show = Show.new
      expect(show.available_galleries).to eq [:posters, :backgrounds, :logos, :videos]
    end
  end
end
