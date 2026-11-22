require "rails_helper"

RSpec.describe Rating, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:item) }
  end

  describe "validations" do
    subject { FactoryBot.create(:rating) }

    it { should validate_uniqueness_of(:item_id).scoped_to([:user_id, :item_type]) }
    it { should allow_values("Movie", "Show", "Season", "Episode").for(:item_type) }
    it { should_not allow_value("User").for(:item_type) }
    it { should validate_numericality_of(:score).only_integer.is_in(1..10) }
  end
end
