require "rails_helper"

RSpec.describe GalleriesController, type: :routing do
  describe "routing" do
    it "routes to #images" do
      expect(get: "/people/1/galleries/images").to route_to("galleries#images", person_id: "1")
    end
  end
end
