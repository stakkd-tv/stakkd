require "rails_helper"

RSpec.describe GenreAssignment, type: :model do
  describe "associations" do
    it { should belong_to(:genre) }
    it { should belong_to(:record) }
  end

  describe "validations" do
    subject { FactoryBot.create(:genre_assignment) }
    it { should validate_uniqueness_of(:genre_id).scoped_to([:record_type, :record_id]) }
  end
end
