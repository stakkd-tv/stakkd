require "rails_helper"
require_relative "shared_examples/slugify"
require_relative "shared_examples/has_galleries"

RSpec.describe Franchise, type: :model do
  describe "validations" do
    it { should validate_presence_of(:translated_title) }
    it { should validate_presence_of(:original_title) }
  end

  it_behaves_like "a model with galleries", :franchise, [:posters, :backgrounds, :logos]

  it_behaves_like "a slugified model", :franchise, :translated_title

  describe "#slug=" do
    it "sets the title_kebab" do
      fran = Franchise.new
      fran.slug = "test"
      expect(fran.title_kebab).to eq "test"
    end
  end
end
