require "rails_helper"

RSpec.describe ContentRatingsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shows/1/content_ratings").to route_to("content_ratings#index", show_id: "1")
    end

    it "routes to #create" do
      expect(post: "/shows/1/content_ratings").to route_to("content_ratings#create", show_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shows/1/content_ratings/1").to route_to("content_ratings#destroy", show_id: "1", id: "1")
    end
  end
end
