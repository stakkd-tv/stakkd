require "rails_helper"

RSpec.describe "shared/_galleries", type: :view do
  it "renders the galleries" do
    movie = FactoryBot.create(
      :movie,
      posters: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")],
      backgrounds: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")],
      logos: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")],
      videos: [FactoryBot.build(:video, thumbnail_url: "/example.png").tap { it.save(validate: false) }]
    )
    presenter = Galleries::Presenter.new(movie)
    render "shared/galleries", presenter: presenter
    assert_select "label", text: "Posters"
    assert_select "label", text: "Backgrounds"
    assert_select "label", text: "Logos"
    assert_select "label", text: "Videos"
    assert_select "img[src*='300x450.png']", count: 3
    assert_select "img[src*='example.png']"
  end
end
