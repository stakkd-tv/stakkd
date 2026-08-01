require "rails_helper"

RSpec.describe "Franchises", type: :request do
  describe "GET /franchises" do
    it "renders a successful response" do
      get shows_url
      expect(response).to be_successful
    end
  end
end
