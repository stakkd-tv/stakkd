require "rails_helper"

RSpec.describe CastMember, type: :model do
  describe "associations" do
    it { should belong_to(:record) }
    it { should belong_to(:person) }
  end

  describe "validations" do
    it { should validate_presence_of :character }
    it { should validate_presence_of :position }
  end
end
