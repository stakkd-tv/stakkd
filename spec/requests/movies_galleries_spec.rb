require "rails_helper"

RSpec.describe "Movies Galleries", type: :request do
  describe "GET /movies/:id/galleries/posters" do
    it "returns http success and renders the posters" do
      movie = FactoryBot.create(:movie, posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get posters_movie_galleries_path(movie)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end

  describe "GET /movies/:id/galleries/logos" do
    it "returns http success and renders the logos" do
      movie = FactoryBot.create(:movie, logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get logos_movie_galleries_path(movie)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end

  describe "GET /movies/:id/galleries/backgrounds" do
    it "returns http success and renders the backgrounds" do
      movie = FactoryBot.create(:movie, backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get backgrounds_movie_galleries_path(movie)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end

  describe "GET /movies/:id/galleries/videos" do
    it "returns http success and renders the videos" do
      movie = FactoryBot.create(:movie, videos: [FactoryBot.build(:video, thumbnail_url: "/example.png").tap { it.save(validate: false) }])
      get videos_movie_galleries_path(movie)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='example.png']"
    end
  end
end
