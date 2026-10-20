require "rails_helper"

RSpec.describe OfficialStacksController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/stacks/official/1").to route_to("official_stacks#show", id: "1")
    end
  end
end
