require "rails_helper"
require_relative "shared_examples/slugify"
require_relative "shared_examples/has_imdb"
require_relative "shared_examples/has_galleries"

RSpec.describe Person, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "associations" do
    it { should have_many(:cast_credits).class_name("CastMember").dependent(:destroy) }
    it { should have_many(:crew_credits).class_name("CrewMember").dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:original_name) }
    it { should validate_presence_of(:translated_name) }
    it { should validate_presence_of(:name_kebab) }
    it { should validate_inclusion_of(:known_for).in_array(Person::CREDITS).allow_blank.allow_nil }
    it { should validate_inclusion_of(:gender).in_array(Person::GENDERS) }
  end

  it_behaves_like "a model with galleries", :person, [:images]

  describe "#image_url" do
    context "when there are no images" do
      it "returns nil" do
        person = Person.new
        expect(person.image_url).to be_nil
      end

      context "when a variant is present" do
        it "returns nil" do
          person = Person.new
          expect(person.image_url(variant: :small)).to be_nil
        end
      end
    end

    context "when there are images" do
      it "returns an image URL" do
        person = FactoryBot.create(
          :person,
          images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
        )
        expect(person.image_url).to be_a(String)
      end

      context "when a variant is present" do
        it "returns an image URL" do
          person = FactoryBot.create(
            :person,
            images: [Rack::Test::UploadedFile.new("spec/support/assets/300x450.png", "image/png")]
          )
          expect(person.image_url(variant: :small)).to be_a(String)
        end
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

  it_behaves_like "a model with imdb_id", Person

  it_behaves_like "a slugified model", :person, :translated_name
end
