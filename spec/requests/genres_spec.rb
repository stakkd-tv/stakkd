require "rails_helper"

RSpec.describe "Genres", type: :request do
  describe "GET /genres" do
    it "renders a successful response" do
      Genre.create!(name: "Action")
      get genres_url
      expect(response).to be_successful
    end
  end
end
