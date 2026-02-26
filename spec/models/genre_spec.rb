require "rails_helper"

RSpec.describe Genre, type: :model do
  describe "associations" do
    it { should have_many(:genre_assignments).dependent(:destroy) }
    it { should have_many(:movies).through(:genre_assignments) }
    it { should have_many(:shows).through(:genre_assignments) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
end
