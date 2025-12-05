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
  end
end
