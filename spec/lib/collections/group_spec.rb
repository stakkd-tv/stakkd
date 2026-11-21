require "rails_helper"

RSpec.describe Collections::Group do
  let(:record) { Show.new }
  subject(:group) do
    described_class.new(record:, added_at: Time.current, owned_count: 5,
      specials_count: 2, unspecified_count: 1, eligible_count: 7, format_counts: {})
  end

  describe "#show?" do
    it "recognizes a show" do
      expect(group).to be_show
    end

    context "with a movie" do
      let(:record) { Movie.new }

      it "does not recognize a movie as a show" do
        expect(group).not_to be_show
      end
    end
  end

  describe "#regular_count" do
    it "excludes owned specials from the ownership count" do
      expect(group.regular_count).to eq(3)
    end
  end
end
