require "rails_helper"

RSpec.describe CrewMember, type: :model do
  describe "associations" do
    it { should belong_to(:record) }
    it { should belong_to(:person) }
    it { should belong_to(:job) }
  end
end
