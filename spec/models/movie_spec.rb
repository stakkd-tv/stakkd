require "rails_helper"

RSpec.describe Movie, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
    it { should belong_to(:language) }
    it { should have_many(:alternative_names).dependent(:delete_all) }
    it { should have_many_attached(:posters) }
    it { should have_many_attached(:backgrounds) }
    it { should have_many_attached(:logos) }
  end

  describe "validations" do
    it { should validate_presence_of(:translated_title) }
    it { should validate_presence_of(:original_title) }
    it { should validate_presence_of(:runtime) }
    it { should validate_presence_of(:revenue) }
    it { should validate_presence_of(:budget) }
    it { should validate_inclusion_of(:status).in_array(Movie::STATUSES) }
  end

  describe "#poster" do
    context "when there are no posters" do
      it "returns the 2:3 asset" do
        movie = Movie.new
        expect(movie.poster).to eq "2:3.png"
      end
    end

    context "when there are posters" do
      it "returns an image" do
        movie = FactoryBot.create(
          :movie,
          posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(movie.poster).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#background" do
    context "when there are no backgrounds" do
      it "returns nil" do
        movie = Movie.new
        expect(movie.background).to be_nil
      end
    end

    context "when there are backgrounds" do
      it "returns an image" do
        movie = FactoryBot.create(
          :movie,
          backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(movie.background).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#logo" do
    context "when there are no logos" do
      it "returns the 1:1 asset" do
        movie = Movie.new
        expect(movie.logo).to eq "1:1.png"
      end
    end

    context "when there are logos" do
      it "returns an image" do
        movie = FactoryBot.create(
          :movie,
          logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(movie.logo).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#imdb_url" do
    it "returns the link to imdb" do
      movie = Movie.new(imdb_id: "tt0000000")
      expect(movie.imdb_url).to eq "https://www.imdb.com/name/tt0000000/"
    end
  end

  describe "#slug=" do
    it "sets the title_kebab" do
      movie = Movie.new
      movie.slug = "test"
      expect(movie.title_kebab).to eq "test"
    end
  end

  describe "#to_s" do
    it "returns the translated title" do
      expect(Movie.new(translated_title: "Test name").to_s).to eq "Test name"
    end
  end
end
