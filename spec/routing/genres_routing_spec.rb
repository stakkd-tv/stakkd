require "rails_helper"

RSpec.describe GenresController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/genres").to route_to("genres#index")
    end
  end
end
