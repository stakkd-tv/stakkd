require "rails_helper"

RSpec.describe FranchiseItem, type: :model do
  describe "associations" do
    it { should belong_to(:franchise) }
    it { should belong_to(:record) }
  end

  describe "validations" do
    subject { FactoryBot.create(:franchise_item) }
    it { should validate_uniqueness_of(:record_id).scoped_to([:record_type]) }
  end

  describe "callbacks" do
    describe "before_validation :set_date" do
      let(:item) { FactoryBot.build(:franchise_item, record:) }

      shared_examples "sets date to record's release_date" do
        it "sets date to record's release_date" do
          expect(item.date).to be_nil
          item.save
          expect(item.date).to eq(Date.new(2026, 1, 1))
        end
      end

      context "when record is a Movie" do
        let(:record) { FactoryBot.create(:movie, :with_release_date, date_for_release: Date.new(2026, 1, 1)) }

        it_behaves_like "sets date to record's release_date"
      end

      context "when record is a Show" do
        let(:record) { FactoryBot.create(:show, :with_premiere_date, date_for_premiere: Date.new(2026, 1, 1)) }

        it_behaves_like "sets date to record's release_date"
      end
    end
  end
end
