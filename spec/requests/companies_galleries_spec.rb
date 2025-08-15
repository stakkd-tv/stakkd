require "rails_helper"

RSpec.describe "Company Galleries", type: :request do
  describe "GET /companies/:id/galleries/logos" do
    it "returns http success and renders the logos" do
      company = FactoryBot.create(:company, logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get logos_company_galleries_path(company)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end
end
