require "rails_helper"

RSpec.describe Video, type: :model do
  describe "associations" do
    it { should belong_to(:record) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:source) }
    it { should validate_presence_of(:source_key) }
    it { should validate_presence_of(:type) }
    it { should validate_inclusion_of(:source).in_array(Video::SOURCES) }
    it { should validate_inclusion_of(:type).in_array(Video::TYPES) }
  end

  describe ".inheritance_column" do
    it "should be empty" do
      expect(Video.inheritance_column).to be_nil
    end
  end
end
