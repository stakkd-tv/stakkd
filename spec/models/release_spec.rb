require "rails_helper"

RSpec.describe Release, type: :model do
  describe "associations" do
    it { should belong_to(:movie) }
    it { should belong_to(:certification) }
    it { should have_one(:country).through(:certification) }
  end

  describe "validations" do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:date) }
    it { should validate_inclusion_of(:type).in_array(Release::TYPES) }
  end

  describe ".inheritance_column" do
    it "should be empty" do
      expect(AlternativeName.inheritance_column).to eq ""
    end
  end
end
