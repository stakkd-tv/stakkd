require "rails_helper"

RSpec.describe AlternativeName, type: :model do
  describe "associations" do
    it { should belong_to(:country) }
    it { should belong_to(:record) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "callbacks" do
    describe "after_save :index_record" do
      it "should index the record" do
        record = FactoryBot.create(:show)
        alternative_name = FactoryBot.create(:alternative_name, record:)
        expect(record).to receive(:index!)
        alternative_name.save
      end

      context "when record is not something that can be indexable" do
        it "does not raise any errors and continues" do
          record = FactoryBot.create(:season) # This is not possible irl but we're still testing it to be safe
          alternative_name = FactoryBot.create(:alternative_name, record:)
          expect{ alternative_name.save }.not_to raise_error
        end
      end
    end

    describe "after_destroy :index_record" do
      it "should index the record" do
        record = FactoryBot.create(:show)
        alternative_name = FactoryBot.create(:alternative_name, record:)
        expect(record).to receive(:index!)
        alternative_name.destroy
      end

      context "when record is not something that can be indexable" do
        it "does not raise any errors and continues" do
          record = FactoryBot.create(:season) # This is not possible irl but we're still testing it to be safe
          alternative_name = FactoryBot.create(:alternative_name, record:)
          expect{ alternative_name.destroy }.not_to raise_error
        end
      end
    end
  end

  describe ".inheritance_column" do
    it "should be empty" do
      expect(AlternativeName.inheritance_column).to be_nil
    end
  end
end
