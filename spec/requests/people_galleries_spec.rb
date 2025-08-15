require "rails_helper"

RSpec.describe "People Galleries", type: :request do
  describe "GET /people/:id/galleries/images" do
    it "returns http success and renders the images" do
      person = FactoryBot.create(:person, images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")])
      get images_person_galleries_path(person)
      expect(response).to have_http_status(:success)
      assert_select "img[src*='300x450.png']"
    end
  end
end
