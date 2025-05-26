require "rails_helper"

RSpec.describe Country, type: :model do
  describe "validations" do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:translated_name) }
    it { should validate_uniqueness_of(:code) }
  end
end
