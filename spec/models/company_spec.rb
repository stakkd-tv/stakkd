require "rails_helper"

RSpec.describe Company, type: :model do
  describe "associations" do
    it { should have_many_attached(:logos) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "#logo" do
    context "when there are no logos" do
      it "returns the 1:1 asset" do
        company = Company.new
        expect(company.logo).to eq "1:1.png"
      end
    end

    context "when there are logos" do
      it "returns an logo" do
        company = FactoryBot.create(
          :company,
          logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(company.logo).to be_a(ActiveStorage::Attachment)
      end
    end
  end
end
