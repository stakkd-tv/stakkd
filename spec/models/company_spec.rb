require "rails_helper"
require_relative "shared_examples/has_galleries"

RSpec.describe Company, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
    it { should have_many(:company_assignments).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  it_behaves_like "a model with galleries", :company, [:logos]

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

  # TODO: Remove this when adding slugs to company
  describe ".from_slug" do
    it "returns the company" do
      company = FactoryBot.create(:company)
      expect(Company.from_slug(company.id)).to eq company
    end
  end
end
