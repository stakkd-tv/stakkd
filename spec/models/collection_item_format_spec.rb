require "rails_helper"

RSpec.describe CollectionItemFormat, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:movie) { FactoryBot.create(:movie, :with_release_date) }
  let(:entry) { user.collection_items.create!(item: movie) }
  before { FactoryBot.create(:collection_format, :common) }

  describe "associations" do
    it { should belong_to(:collection_item) }
    it { should belong_to(:collection_format) }
  end

  describe "validations" do
    subject { FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: CollectionFormat.common.first!) }

    it { should validate_uniqueness_of(:collection_format_id).scoped_to(:collection_item_id) }

    it "accepts the owner's custom format" do
      custom = user.collection_formats.create!(name: "VHS")
      expect(described_class.new(collection_item: entry, collection_format: custom)).to be_valid
    end

    it "validates missing associations without raising" do
      expect(described_class.new).not_to be_valid
    end
  end

  describe "after_destroy :prune_unused_formats" do
    it "passes the collection owner's id to cleanup" do
      assignment = FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: CollectionFormat.common.first!)
      expect(CollectionFormat).to receive(:prune_unused_for).with(user.id).and_call_original
      assignment.destroy!
    end

    it "removes a custom format after its last assignment is destroyed" do
      custom = user.collection_formats.create!(name: "VHS")
      assignment = FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: custom)
      fetched = described_class.find(assignment.id)
      fetched.destroy!
      expect(fetched.association(:collection_item)).not_to be_loaded
      expect(CollectionFormat.exists?(custom.id)).to be(false)
      expect(entry.reload).to be_persisted
    end

    it "retains formats still assigned to another item" do
      custom = user.collection_formats.create!(name: "VHS")
      assignment = FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: custom)
      other_entry = FactoryBot.create(:collection_item, user:)
      FactoryBot.create(:collection_item_format, collection_item: other_entry, collection_format: custom)
      assignment.destroy!
      expect(custom.reload).to be_persisted
    end

    it "retains common formats after their last assignment is destroyed" do
      common = CollectionFormat.common.first!
      assignment = FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: common)
      assignment.destroy!
      expect(common.reload).to be_persisted
    end
  end

  describe "database constraints and validations" do
    it "rejects duplicate format assignments in the database" do
      format = CollectionFormat.common.first!
      CollectionItemFormat.create!(collection_item: entry, collection_format: format)
      expect do
        CollectionItemFormat.transaction(requires_new: true) do
          CollectionItemFormat.insert_all!([{collection_item_id: entry.id, collection_format_id: format.id}])
        end
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "rejects assigning a private format to another user's ownership" do
      format = FactoryBot.create(:user).collection_formats.create!(name: "VHS")
      assignment = CollectionItemFormat.new(collection_item: entry, collection_format: format)
      expect(assignment).not_to be_valid
      expect(assignment.errors[:collection_format]).to be_present
    end
  end
end
