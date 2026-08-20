require "rails_helper"
require_relative "shared_examples/slugify"
require_relative "shared_examples/has_galleries"
require_relative "shared_examples/routable"

RSpec.describe Franchise, type: :model do
  describe "associations" do
    it { should have_many(:franchise_items).dependent(:destroy) }
    it { should have_many(:ordered_franchise_items).class_name("FranchiseItem") }
  end

  describe "validations" do
    it { should validate_presence_of(:translated_title) }
    it { should validate_presence_of(:original_title) }
  end

  it_behaves_like "a model with galleries", :franchise, [:posters, :backgrounds, :logos]

  it_behaves_like "a slugified model", :franchise, :translated_title

  describe ".search_schema" do
    it "returns the search schema" do
      expect(Franchise.search_schema).to eq([
        {"name" => "original_title", "type" => "string"},
        {"name" => "translated_title", "type" => "string", "sort" => true},
        {"name" => "slug", "type" => "string"}
      ])
    end
  end

  describe "#slug=" do
    it "sets the title_kebab" do
      fran = Franchise.new
      fran.slug = "test"
      expect(fran.title_kebab).to eq "test"
    end
  end

  describe "#to_s" do
    it "returns the translated title" do
      fran = Franchise.new(translated_title: "Test Franchise")
      expect(fran.to_s).to eq "Test Franchise"
    end
  end

  it_behaves_like "a routable model" do
    let(:record) { FactoryBot.create(:franchise) }
    let(:ordered_related_records) { [record] }
    let(:route_name) { "franchise" }
    let(:related_records) { {franchise: record} }
    let(:records_for_polymorphic_paths) { {id: record} }
    let(:records_for_polymorphic_paths_with_full_id) { {franchise_id: record} }
  end
end
