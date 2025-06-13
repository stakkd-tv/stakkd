require "rails_helper"

RSpec.describe AlternativeName, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
    it { should belong_to(:record) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe ".inheritance_column" do
    it "should be empty" do
      expect(AlternativeName.inheritance_column).to eq ""
    end
  end
end
