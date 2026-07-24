require "rails_helper"

RSpec.describe SearchController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/search").to route_to("search#index")
    end

    it "routes to #show" do
      expect(get: "/search/movies").to route_to("search#show", id: "movies")
    end
  end
end
