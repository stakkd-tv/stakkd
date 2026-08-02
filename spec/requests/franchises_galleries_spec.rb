require "rails_helper"

RSpec.describe "Franchises Galleries", type: :request do
  describe "GET /franchises/:id/galleries/posters" do
    it "returns http success and renders the posters" do
      franchise = FactoryBot.create(:franchise, posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get posters_franchise_galleries_path(franchise)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end

  describe "GET /franchises/:id/galleries/logos" do
    it "returns http success and renders the logos" do
      franchise = FactoryBot.create(:franchise, logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get logos_franchise_galleries_path(franchise)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end

  describe "GET /franchises/:id/galleries/backgrounds" do
    it "returns http success and renders the backgrounds" do
      franchise = FactoryBot.create(:franchise, backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get backgrounds_franchise_galleries_path(franchise)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end
end
