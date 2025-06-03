require "rails_helper"

RSpec.describe ActiveStorage::Attachment, type: :model do
  describe "after_create :extract_colour" do
    it "enqueues a colour extraction job" do
      expect(ExtractColourJob).to receive(:perform_later)
      FactoryBot.create(:person, images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
    end
  end

  describe "#dominant_colour" do
    it "returns the most vibrant, dominant colour" do
      image = ActiveStorage::Attachment.new(colours: ["#ffffff", "#000000", "#36A2C8"])
      expect(image.dominant_colour).to eq "#36A2C8"
    end
  end

  describe "#filtered_colours" do
    it "filters out any dull/grey colours" do
      image = ActiveStorage::Attachment.new(colours: ["#ffffff", "#000000", "#36A2C8"])
      expect(image.filtered_colours).to eq ["#36A2C8"]
    end
  end
end
