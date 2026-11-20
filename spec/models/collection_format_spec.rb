require "rails_helper"

RSpec.describe CollectionFormat, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe "associations" do
    it { should belong_to(:user).optional }
    it { should have_many(:collection_item_formats).dependent(:restrict_with_exception) }
  end

  describe "validations" do
    subject { FactoryBot.create(:collection_format) }

    it { should validate_presence_of(:name) }
    it "rejects duplicate custom names after normalization" do
      user.collection_formats.create!(name: "VHS")
      duplicate = user.collection_formats.build(name: " vhs ")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:normalized_name]).to be_present
    end

    it "allows different users to reuse a custom name" do
      user.collection_formats.create!(name: "VHS")
      expect(FactoryBot.create(:user).collection_formats.create!(name: "VHS")).to be_persisted
    end

    it "prevents duplicate common names" do
      FactoryBot.create(:collection_format, :common)
      expect(FactoryBot.build(:collection_format, :common, name: "blu-ray")).not_to be_valid
    end
  end

  describe "before_validation :normalize_name" do
    it "strips the display name and lowercases the matching name" do
      format = user.collection_formats.create!(name: " VHS ")
      expect(format.name).to eq("VHS")
      expect(format.normalized_name).to eq("vhs")
    end

    it "handles missing and whitespace names without raising" do
      [nil, " \t "].each do |name|
        format = described_class.new(name:)
        expect(format).not_to be_valid
        expect(format.normalized_name).to eq("")
      end
    end

    it "updates the matching name when a name changes" do
      format = user.collection_formats.create!(name: "VHS")
      format.update!(name: " Digital — Apple TV ")
      expect(format.normalized_name).to eq("digital — apple tv")
    end

    it "supports Unicode independently of the database collation" do
      expect(user.collection_formats.create!(name: "Édition numérique").normalized_name).to eq("édition numérique")
    end
  end

  describe ".common" do
    it "includes common formats and excludes user formats" do
      common = FactoryBot.create(:collection_format, :common)
      FactoryBot.create(:collection_format)
      expect(described_class.common).to eq([common])
    end
  end

  describe ".available_to" do
    it "returns common formats and the user's custom formats only" do
      common = FactoryBot.create(:collection_format, :common)
      custom = FactoryBot.create(:collection_format, user:)
      FactoryBot.create(:collection_format)
      expect(described_class.available_to(user)).to match_array([common, custom])
    end
  end

  describe ".prune_unused_for" do
    it "deletes only unused custom formats for the given user" do
      unused = FactoryBot.create(:collection_format, user:)
      used = FactoryBot.create(:collection_format, user:, name: "LaserDisc")
      common = FactoryBot.create(:collection_format, :common)
      other = FactoryBot.create(:collection_format)
      entry = FactoryBot.create(:collection_item, user:)
      FactoryBot.create(:collection_item_format, collection_item: entry, collection_format: used)
      described_class.prune_unused_for(user.id)
      expect(described_class.exists?(unused.id)).to be(false)
      expect(described_class.where(id: [used.id, common.id, other.id]).count).to eq(3)
    end

    it "does nothing without a user id" do
      common = FactoryBot.create(:collection_format, :common)
      expect { described_class.prune_unused_for(nil) }.not_to change(described_class, :count)
      expect(common.reload).to be_persisted
    end
  end

  describe "database constraints" do
    it "enforces custom name uniqueness" do
      user.collection_formats.create!(name: "VHS")
      expect do
        described_class.transaction(requires_new: true) do
          described_class.insert_all!([{user_id: user.id, name: "vhs", normalized_name: "vhs"}])
        end
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "enforces common name uniqueness" do
      FactoryBot.create(:collection_format, :common)
      expect do
        described_class.transaction(requires_new: true) do
          described_class.insert_all!([{name: "Blu-ray", normalized_name: "blu-ray"}])
        end
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "rejects blank names when validations are bypassed" do
      expect do
        described_class.transaction(requires_new: true) do
          described_class.insert_all!([{name: " ", normalized_name: " "}])
        end
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
