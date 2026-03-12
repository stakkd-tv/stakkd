RSpec.shared_examples_for "a model with imdb_id" do |model|
  describe "#imdb_url" do
    it "returns the link to imdb" do
      obj = model.new(imdb_id: "tt0000000")
      expect(obj.imdb_url).to eq "https://www.imdb.com/title/tt0000000/"
    end

    context "when imdb_id is nil" do
      it "returns nil" do
        obj = model.new(imdb_id: nil)
        expect(obj.imdb_url).to be_nil
      end
    end

    context "when imdb_id starts with nm" do
      it "returns the link to imdb" do
        obj = model.new(imdb_id: "nm0000000")
        expect(obj.imdb_url).to eq "https://www.imdb.com/name/nm0000000/"
      end
    end
  end
end
