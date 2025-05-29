require "rails_helper"

module Uploads
  RSpec.describe ColourExtractor do
    let(:person) { FactoryBot.create(:person, images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]) }
    let(:attachment) { person.images.first }

    describe "delegated methods" do
      subject { ColourExtractor.new(attachment:) }
      it { should delegate_method(:blob).to(:attachment) }
    end

    describe "#extract" do
      it "returns an array of colours sorted by dominance" do
        output = "          4929: (53,53,53) #353535 gray(53)\n           696: (159,159,159) #9F9F9F gray(159)"
        expect(MiniMagick).to receive(:convert).and_return(output)
        colours = ColourExtractor.new(attachment:).extract
        expect(colours).to eq ["#9F9F9F", "#353535"]
      end
    end
  end
end
