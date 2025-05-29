require "rails_helper"

RSpec.describe ImagesController, type: :routing do
  describe "routing" do
    it "routes to #upload" do
      expect(post: "/uploads").to route_to("images#upload")
    end
  end
end
