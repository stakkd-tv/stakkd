require "rails_helper"

RSpec.describe "Season Galleries", type: :request do
  describe "GET /show/:show_id/seasons/:id/galleries/posters" do
    it "returns http success and renders the posters" do
      season = FactoryBot.create(:season, posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get posters_show_season_galleries_path(season, show_id: season.show)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end

  describe "GET /show/:show_id/seasons/:id/galleries/videos" do
    it "returns http success and renders the videos" do
      season = FactoryBot.create(:season, videos: [FactoryBot.build(:video, thumbnail_url: "/example.png").tap { it.save(validate: false) }])
      get videos_show_season_galleries_path(season, show_id: season.show)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='example.png']"
    end
  end
end
