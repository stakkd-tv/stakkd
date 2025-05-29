require "rails_helper"

RSpec.describe ExtractColourJob, type: :job do
  context "when the attachment could not be found" do
    it "does not do anything" do
      expect(Uploads::ColourExtractor).not_to receive(:new)
      ExtractColourJob.new.perform(1)
    end
  end

  context "when the attachment is present" do
    let!(:person) { FactoryBot.create(:person, images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]) }

    it "uses the colour extractor and updates the attachment" do
      attachment = ActiveStorage::Attachment.first
      extractor = instance_double(Uploads::ColourExtractor)
      expect(Uploads::ColourExtractor).to receive(:new).with(attachment:).and_return(extractor)
      expect(extractor).to receive(:extract).and_return(["#eee"])
      ExtractColourJob.new.perform(attachment.id)
      attachment.reload
      expect(attachment.colours).to eq ["#eee"]
    end

    context "when no colours could be extracted" do
      it "does not update the attachment" do
        attachment = ActiveStorage::Attachment.first
        extractor = instance_double(Uploads::ColourExtractor)
        expect(Uploads::ColourExtractor).to receive(:new).with(attachment:).and_return(extractor)
        expect(extractor).to receive(:extract).and_return([])
        ExtractColourJob.new.perform(attachment.id)
        attachment.reload
        expect(attachment.colours).to eq ["#f7567c"]
      end
    end
  end
end
