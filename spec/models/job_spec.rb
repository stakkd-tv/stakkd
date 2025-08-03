require "rails_helper"

RSpec.describe Job, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:department) }
  end
end
