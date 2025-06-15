require "rails_helper"

RSpec.describe GenreAssignmentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/movies/1/genre_assignments").to route_to("genre_assignments#index", movie_id: "1")
    end

    it "routes to #create" do
      expect(post: "/movies/1/genre_assignments").to route_to("genre_assignments#create", movie_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/movies/1/genre_assignments/1").to route_to("genre_assignments#destroy", movie_id: "1", id: "1")
    end
  end
end
