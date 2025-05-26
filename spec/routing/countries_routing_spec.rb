require "rails_helper"

RSpec.describe CountriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/countries").to route_to("countries#index")
    end
  end
end
