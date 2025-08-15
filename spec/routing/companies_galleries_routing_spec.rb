require "rails_helper"

RSpec.describe GalleriesController, type: :routing do
  describe "routing" do
    it "routes to #logos" do
      expect(get: "/companies/1/galleries/logos").to route_to("galleries#logos", company_id: "1")
    end
  end
end
