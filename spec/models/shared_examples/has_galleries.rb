shared_examples "a model with galleries" do |factory, galleries|
  describe "attached galleries" do
    if galleries.include?(:videos)
      it { should have_many(:videos).dependent(:destroy) }
    end
    (galleries - [:videos]).each do |gallery|
      it { should have_many_attached(gallery) }
    end
  end

  (galleries - [:videos]).each do |gallery|
    describe "##{gallery.to_s.singularize}" do
      context "when there are no #{gallery}" do
        context "when use_fallback is true" do
          it "returns the fallback asset" do
            object = FactoryBot.create(factory)
            expect(object.send(gallery.to_s.singularize)).to eq HasGalleries::GALLERY_FALLBACKS[gallery]
          end
        end

        context "when use_fallback is false" do
          it "returns nil" do
            object = FactoryBot.create(factory)
            expect(object.send(gallery.to_s.singularize, use_fallback: false)).to be_nil
          end
        end
      end

      context "when there are #{gallery}" do
        it "returns an image" do
          object = FactoryBot.create(
            factory,
            gallery => [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
          )
          expect(object.send(gallery.to_s.singularize)).to be_a(ActiveStorage::Attachment)
        end
      end
    end
  end

  describe "#available_galleries" do
    it "returns the available galleries" do
      object = FactoryBot.create(factory)
      expect(object.available_galleries).to eq galleries
    end
  end
end
