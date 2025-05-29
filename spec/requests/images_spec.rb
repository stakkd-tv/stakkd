require "rails_helper"

RSpec.describe "Images", type: :request do
  describe "POST /uploads" do
    let(:record) { FactoryBot.create(:person) }
    let(:record_id) { record.id }
    let(:record_type) { record.class.to_s }
    let(:type) { "images" }
    let(:image) { Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png") }

    def perform
      post upload_path, params: {record_id:, record_type:, type:, image:}
    end

    context "when the record_id is not present" do
      let(:record_id) { "" }

      it "renders a json error" do
        perform
        expect(response.status).to eq 400
        json = JSON.parse(response.body)
        expect(json["message"]).to eq "Record ID is not present"
      end
    end

    context "when the record_type is invalid" do
      let(:record_type) { "BogusClass" }

      it "renders a json error" do
        perform
        expect(response.status).to eq 400
        json = JSON.parse(response.body)
        expect(json["message"]).to eq "Invalid record type"
      end
    end

    context "when the type is invalid" do
      let(:type) { "invalid_bogus_type" }

      it "renders a json error" do
        perform
        expect(response.status).to eq 400
        json = JSON.parse(response.body)
        expect(json["message"]).to eq "Invalid type"
      end
    end

    context "when the image is not present" do
      let(:image) { nil }

      it "renders a json error" do
        perform
        expect(response.status).to eq 400
        json = JSON.parse(response.body)
        expect(json["message"]).to eq "No image supplied"
      end
    end

    context "when the image param is not a file" do
      let(:image) { "invalid" }

      it "renders a json error" do
        perform
        expect(response.status).to eq 400
        json = JSON.parse(response.body)
        expect(json["message"]).to eq "Not a valid file"
      end
    end

    context "when the uploaded file is not a valid image" do
      let(:image) { Rack::Test::UploadedFile.new("spec/requests/images_spec.rb", "text/plain") }

      it "renders a json error" do
        perform
        expect(response.status).to eq 400
        json = JSON.parse(response.body)
        expect(json["message"]).to eq "Invalid content type"
      end
    end

    context "when the upload fails" do
      let(:image) { Rack::Test::UploadedFile.new("spec/support/assets/299x449.png", "image/png") }

      it "renders a json error" do
        perform
        expect(response.status).to eq 422
        json = JSON.parse(response.body)
        expect(json["message"]).to eq "Width must be between 300px and 2000px, Height must be between 450px and 3000px"
      end
    end

    context "when the upload succeeds" do
      it "renders json with the image url" do
        perform
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json["image"]).to match(/.*\/300x450.png/)
      end

      it "attaches the image" do
        perform
        expect(record.images.count).to eq 1
      end
    end
  end
end
