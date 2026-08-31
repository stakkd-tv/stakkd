require "rails_helper"

module Users
  RSpec.describe StacksController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(get: "/users/1/stacks").to route_to("users/stacks#index", user_id: "1")
      end

      it "routes to #new" do
        expect(get: "/users/1/stacks/new").to route_to("users/stacks#new", user_id: "1")
      end

      it "routes to #create" do
        expect(post: "/users/1/stacks").to route_to("users/stacks#create", user_id: "1")
      end

      it "routes to #destroy" do
        expect(delete: "/users/1/stacks/1").to route_to("users/stacks#destroy", user_id: "1", id: "1")
      end
    end
  end
end
