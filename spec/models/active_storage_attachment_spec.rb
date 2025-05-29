require "rails_helper"

RSpec.describe ActiveStorage::Attachment, type: :model do
  describe "after_create :extract_colour" do
    it "enqueues a colour extraction job" do
      expect(ExtractColourJob).to receive(:perform_later)
      FactoryBot.create(:person, images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
    end
  end

  describe "#dominant_colour" do
    it "returns the dominant colour" do
      person = FactoryBot.create(:person, images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      expect(person.images.first.dominant_colour).to eq "#f7567c"
    end
  end
end
