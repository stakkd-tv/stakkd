require "rails_helper"

RSpec.describe ContentRating, type: :model do
  describe "associations" do
    it { should belong_to(:show) }
    it { should belong_to(:certification) }
  end

  describe "validations" do
    subject { FactoryBot.create(:content_rating) }

    it { should validate_uniqueness_of(:show_id).scoped_to(:certification_id) }
  end
end
