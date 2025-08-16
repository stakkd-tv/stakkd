require "rails_helper"

module Galleries
  RSpec.describe Presenter, type: :presenter do
    describe "#tabs" do
      it "returns the information for the records galleries" do
        movie = FactoryBot.create(
          :movie,
          posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")],
          backgrounds: [
            Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png"),
            Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png"),
            Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png"),
            Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")
          ],
          logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")],
          videos: [FactoryBot.build(:video, thumbnail_url: "/example.png").tap { it.save(validate: false) }]
        )
        presenter = Presenter.new(movie)
        expect(presenter.tabs).to eq([
          {
            name: "Posters",
            images: movie.posters.to_a,
            aspect: "min-w-40 max-w-40 aspect-2/3",
            show_view_more: false,
            view_more_path: "/movies/#{movie.slug}/galleries/posters",
            partial: "shared/gallery"
          },
          {
            name: "Backgrounds",
            images: movie.backgrounds.take(3),
            aspect: "min-w-[425px] max-w-[425px] aspect-16/9",
            show_view_more: true,
            view_more_path: "/movies/#{movie.slug}/galleries/backgrounds",
            partial: "shared/gallery"
          },
          {
            name: "Logos",
            images: movie.logos.to_a,
            aspect: "min-w-60 max-w-60 aspect-square",
            show_view_more: false,
            view_more_path: "/movies/#{movie.slug}/galleries/logos",
            partial: "shared/gallery"
          },
          {
            name: "Videos",
            images: movie.videos.to_a,
            aspect: "min-w-[425px] max-w-[425px] aspect-16/9",
            show_view_more: false,
            view_more_path: "/movies/#{movie.slug}/galleries/videos",
            partial: "shared/video_gallery"
          }
        ])
      end
    end
  end
end
