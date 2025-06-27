require "rails_helper"

RSpec.describe CompanyAssignment, type: :model do
  describe "associations" do
    it { should belong_to(:company) }
    it { should belong_to(:record) }
  end

  describe "validations" do
    subject { FactoryBot.create(:company_assignment) }
    it { should validate_uniqueness_of(:company_id).scoped_to([:record_type, :record_id]) }
  end
end
