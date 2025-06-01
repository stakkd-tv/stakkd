require "rails_helper"
require_relative "shared_examples/slugify"

RSpec.describe Person, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "associations" do
    it { should have_many_attached(:images) }
  end

  describe "validations" do
    it { should validate_presence_of(:original_name) }
    it { should validate_presence_of(:translated_name) }
    it { should validate_presence_of(:name_kebab) }
    it { should validate_inclusion_of(:known_for).in_array(Person::CREDITS).allow_blank.allow_nil }
    it { should validate_inclusion_of(:gender).in_array(Person::GENDERS) }
  end

  describe "#image" do
    context "when there are no images" do
      it "returns the 2:3 asset" do
        person = Person.new
        expect(person.image).to eq "2:3.png"
      end
    end

    context "when there are images" do
      it "returns an image" do
        person = FactoryBot.create(
          :person,
          images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(person.image).to be_a(ActiveStorage::Attachment)
      end
    end
  end

  describe "#age" do
    context "when there is no dob" do
      it "returns nil" do
        person = Person.new
        expect(person.age).to be_nil
      end
    end

    context "when there is no dod" do
      it "returns the age up until the current time" do
        travel_to Date.new(2027, 1, 1)
        person = Person.new(dob: Date.new(2025, 1, 1))
        expect(person.age).to eq 2
      end
    end

    context "when there is a dod" do
      it "returns the age up until the dod" do
        person = Person.new(dob: Date.new(2025, 1, 1), dod: Date.new(2026, 1, 1))
        expect(person.age).to eq 1
      end
    end

    it "rounds the age down to an int" do
      person = Person.new(dob: Date.new(2025, 1, 1), dod: Date.new(2026, 12, 31))
      expect(person.age).to eq 1
    end
  end

  describe "imdb_url" do
    it "returns the link to imdb" do
      person = Person.new(imdb_id: "nm0000000")
      expect(person.imdb_url).to eq "https://www.imdb.com/name/nm0000000/"
    end
  end

  it_behaves_like "a slugified model", :person, :translated_name
end
