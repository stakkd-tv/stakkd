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
end
