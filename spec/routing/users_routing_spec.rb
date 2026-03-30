require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/users/new").to route_to("users#new")
    end

    it "routes to #show" do
      expect(get: "/users/1").to route_to("users#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/users").to route_to("users#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/users/1").to route_to("users#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/users/1").to route_to("users#update", id: "1")
    end

    it "routes to #confirm" do
      expect(get: "/users/confirm").to route_to("users#confirm")
    end

    it "routes to #settings" do
      expect(get: "/settings").to route_to("users#settings")
    end
  end
end
