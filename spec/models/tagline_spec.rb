require "rails_helper"

RSpec.describe Tagline, type: :model do
  describe "associations" do
    it { should belong_to(:record) }
  end

  describe "validations" do
    it { should validate_presence_of(:tagline) }
    it { should validate_presence_of(:position) }
  end
end
