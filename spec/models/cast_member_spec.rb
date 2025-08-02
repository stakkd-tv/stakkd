require "rails_helper"

RSpec.describe CastMember, type: :model do
  describe "associations" do
    it { should belong_to(:record) }
    it { should belong_to(:person) }
  end

  describe "validations" do
    subject { FactoryBot.create(:cast_member) }

    it { should validate_presence_of :character }
    it { should validate_presence_of :position }
    it { should validate_uniqueness_of(:person_id).scoped_to([:record_type, :record_id]) }
  end
end
