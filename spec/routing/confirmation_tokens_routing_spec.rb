require "rails_helper"

RSpec.describe ConfirmationTokensController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "/confirmations").to route_to("confirmation_tokens#create")
    end

    it "routes to #new" do
      expect(get: "/confirmations/new").to route_to("confirmation_tokens#new")
    end
  end
end
