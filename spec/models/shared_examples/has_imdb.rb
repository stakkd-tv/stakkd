RSpec.shared_examples_for "a model with imdb_id" do |model|
  describe "#imdb_url" do
    it "returns the link to imdb" do
      obj = model.new(imdb_id: "tt0000000")
      expect(obj.imdb_url).to eq "https://www.imdb.com/title/tt0000000/"
    end
  end
end
