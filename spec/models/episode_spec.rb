require "rails_helper"

RSpec.describe Episode, type: :model do
  describe "associations" do
    it { should belong_to(:season) }
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
end
