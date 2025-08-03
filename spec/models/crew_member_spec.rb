require "rails_helper"

RSpec.describe CrewMember, type: :model do
  describe "associations" do
    it { should belong_to(:record) }
    it { should belong_to(:person) }
    it { should belong_to(:job) }
  end

  describe "validations" do
    subject { FactoryBot.create(:crew_member) }

    it { should validate_uniqueness_of(:person_id).scoped_to([:record_type, :record_id]) }
  end
end
