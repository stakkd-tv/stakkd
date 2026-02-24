require "rails_helper"

RSpec.describe Season, type: :model do
  describe "associations" do
    it { should belong_to(:show) }
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
end
