require "rails_helper"

RSpec.describe "shared/_colour_from_image", type: :view do
  context "when it is not an image" do
    it "does" do
      image = ActiveStorage::Attachment.new(colours: ["#7556BB"])
      render "shared/colour_from_image", image: image
      expect(rendered).to match(/--color-pop: #7556BB;/)
    end
  end

  context "when it is not an image" do
    it "does not render" do
      render "shared/colour_from_image", image: nil
      expect(rendered).to eq ""
    end
  end
end
