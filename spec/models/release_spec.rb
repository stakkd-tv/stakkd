require "rails_helper"

RSpec.describe Release, type: :model do
  describe "associations" do
    it { should belong_to(:movie) }
    it { should belong_to(:certification) }
    it { should belong_to(:language) }
  end

  describe "validations" do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:date) }
  end
end
