require "rails_helper"

RSpec.describe ExtractColourJob, type: :job do
  context "when the blob could not be found" do
    it "does not do anything" do
      expect(Uploads::ColourExtractor).not_to receive(:new)
      ExtractColourJob.new.perform(1)
    end
  end

  context "when the blob is present" do
    let!(:person) { FactoryBot.create(:person, images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]) }

    it "uses the colour extractor and updates the attachment" do
      blob = ActiveStorage::Blob.first
      extractor = instance_double(Uploads::ColourExtractor)
      expect(Uploads::ColourExtractor).to receive(:new).with(blob:).and_return(extractor)
      expect(extractor).to receive(:extract).and_return(["#eee"])
      ExtractColourJob.new.perform(blob.id)
      blob.reload
      expect(blob.colours).to eq ["#eee"]
    end

    context "when no colours could be extracted" do
      it "does not update the blob" do
        blob = ActiveStorage::Blob.first
        extractor = instance_double(Uploads::ColourExtractor)
        expect(Uploads::ColourExtractor).to receive(:new).with(blob:).and_return(extractor)
        expect(extractor).to receive(:extract).and_return([])
        ExtractColourJob.new.perform(blob.id)
        blob.reload
        expect(blob.colours).to eq ["#f7567c"]
      end
    end
  end
end
