RSpec.shared_examples_for "a routable model" do
  describe "#ordered_related_records" do
    it "returns the related records in order" do
      expect(record.ordered_related_records).to eq(ordered_related_records)
    end
  end

  describe "#route_name" do
    it "returns the route name for the record" do
      expect(record.route_name).to eq route_name
    end
  end

  describe "#related_records" do
    it "includes the show in the hash" do
      expect(record.related_records).to eq(related_records)
    end
  end

  describe "#records_for_polymorphic_paths" do
    it "returns the related records in a hash for path helpers" do
      expect(record.records_for_polymorphic_paths).to eq(records_for_polymorphic_paths)
    end
  end

  describe "#records_for_polymorphic_paths_with_full_id" do
    it "returns the related records in a hash for path helpers with the full id" do
      expect(record.records_for_polymorphic_paths_with_full_id).to eq(records_for_polymorphic_paths_with_full_id)
    end
  end
end
