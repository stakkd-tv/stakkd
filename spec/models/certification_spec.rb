require "rails_helper"

RSpec.describe Certification, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
  end

  describe "validations" do
    it { should validate_inclusion_of(:media_type).in_array(Certification::MEDIA_TYPES) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:position) }
  end

  describe ".for_movies" do
    it "returns certifications for movies" do
      certification = FactoryBot.create(:certification, media_type: "Movie")
      FactoryBot.create(:certification, media_type: "Show")
      expect(Certification.for_movies).to eq [certification]
    end
  end

  describe "#to_s" do
    it "returns the country code and certification" do
      certification = FactoryBot.create(:certification, code: "ABC", country: FactoryBot.create(:country, code: "UK"))
      expect(certification.to_s).to eq "UK - ABC"
    end
  end
end
