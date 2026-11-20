require "rails_helper"

RSpec.describe CollectionItem, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:movie) { FactoryBot.create(:movie, :with_release_date) }
  let(:entry) { user.collection_items.create!(item: movie) }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:item) }
    it { should have_many(:collection_item_formats).dependent(:destroy) }
    it { should have_many(:formats).through(:collection_item_formats).source(:collection_format) }
  end

  describe "validations" do
    subject { FactoryBot.create(:collection_item) }

    it "accepts movies and episodes" do
      [FactoryBot.create(:movie), FactoryBot.create(:episode)].each do |item|
        expect(described_class.new(user:, item:)).to be_valid
      end
    end

    it "rejects show and season ownership" do
      [FactoryBot.create(:show), FactoryBot.create(:season)].each do |item|
        record = described_class.new(user:, item:)
        expect(record).not_to be_valid
        expect(record.errors[:item_type]).to be_present
      end
    end
    it { should validate_uniqueness_of(:item_id).scoped_to([:user_id, :item_type]) }
  end

  describe "before_destroy :preload_format_assignments" do
    it "destroys assignments and prunes custom formats under strict loading" do
      format = user.collection_formats.create!(name: "VHS")
      FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: format)
      described_class.find(entry.id).destroy!
      expect(CollectionItemFormat.where(collection_item_id: entry.id)).to be_empty
      expect(CollectionFormat.exists?(format.id)).to be(false)
    end
  end

  describe "database constraints and validations" do
    it "rejects duplicate ownership at the database boundary" do
      entry
      expect do
        CollectionItem.transaction(requires_new: true) do
          CollectionItem.insert_all!([{user_id: user.id, item_type: "Movie", item_id: movie.id}])
        end
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "rejects show ownership even when validations are bypassed" do
      expect do
        CollectionItem.transaction(requires_new: true) do
          CollectionItem.insert_all!([{user_id: user.id, item_type: "Show", item_id: 1}])
        end
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
