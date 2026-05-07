require "rails_helper"

RSpec.describe ActiveStorage::VariantWithRecord, type: :model do
  describe "delegations" do
    subject { ActiveStorage::VariantWithRecord.new(ActiveStorage::Blob.new, {}) }
    it { should delegate_method(:dominant_colour).to(:blob) }
    it { should delegate_method(:filtered_colours).to(:blob) }
  end
end
