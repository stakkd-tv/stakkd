require "rails_helper"

RSpec.describe Company, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
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

  describe "#logo_url" do
    context "when there are no logos" do
      it "returns nil" do
        company = Company.new
        expect(company.logo_url).to be_nil
      end
    end

    context "when there are logos" do
      it "returns a logo URL" do
        company = FactoryBot.create(
          :company,
          logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(company.logo_url).to be_a(String)
      end
    end
  end

  describe "#available_galleries" do
    it "returns the available galleries" do
      company = Company.new
      expect(company.available_galleries).to eq [:logos]
    end
  end

  # TODO: Remove this when adding slugs to company
  describe ".from_slug" do
    it "returns the company" do
      company = FactoryBot.create(:company)
      expect(Company.from_slug(company.id)).to eq company
    end
  end
end
