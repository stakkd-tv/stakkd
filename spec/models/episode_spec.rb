require "rails_helper"

RSpec.describe Episode, type: :model do
  describe "associations" do
    it { should belong_to(:season) }
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

  describe ".ordered" do
    it "returns the seasons in order of number" do
      episode2 = FactoryBot.create(:episode, number: 2)
      episode1 = FactoryBot.create(:episode, number: 1)
      expect(Episode.ordered).to eq [episode1, episode2]
    end
  end

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
