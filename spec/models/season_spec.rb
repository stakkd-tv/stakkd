require "rails_helper"

RSpec.describe Season, type: :model do
  describe "associations" do
    it { should belong_to(:show) }
  end

  describe "validations" do
    subject { FactoryBot.create(:season) }
    it { should validate_presence_of(:translated_name) }
    it { should validate_presence_of(:original_name) }
    it { should validate_uniqueness_of(:number).scoped_to([:show_id]) }
    it { should validate_numericality_of(:number).is_greater_than_or_equal_to(0) }
  end
end
