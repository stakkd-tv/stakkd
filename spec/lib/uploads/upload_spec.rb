require "rails_helper"

module Uploads
  RSpec.describe Upload do
    let(:record) { FactoryBot.create(:person) }
    let(:field) { :images }
    let(:image) { Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png") }
    let(:validator_class) { Uploads::Validators::PersonImagesValidator }
    let(:uploader) { Upload.new(record:, field:, image:, validator_class:) }

    describe "delegated methods" do
      subject { uploader }
      it { should delegate_method(:errors).to(:validator) }
      it { should delegate_method(:url).to(:blob) }
    end

    describe "#validate_and_save!" do
      context "when the upload is valid" do
        it "returns true" do
          expect(uploader.validate_and_save!).to eq true
        end

        it "attaches the image to the record" do
          uploader.validate_and_save!
          expect(record.images.count).to eq 1
        end
      end

      context "when the upload is not valid" do
        let(:image) { Rack::Test::UploadedFile.new("spec/support/assets/299x449.png", "image/png") }

        it "returns false" do
          expect(uploader.validate_and_save!).to eq false
        end

        it "purges the image" do
          expect_any_instance_of(ActiveStorage::Blob).to receive(:purge)
          uploader.validate_and_save!
        end
      end
    end
  end
end
