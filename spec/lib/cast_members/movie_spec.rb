require "rails_helper"

module CastMembers
  RSpec.describe Movie do
    describe "#cast_members" do
      it "returns the cast members ordered by position" do
        movie = FactoryBot.create(:movie)
        person1 = FactoryBot.build(:person, translated_name: "John Doe")
        person2 = FactoryBot.build(:person, translated_name: "Jane Doe")
        cm1 = FactoryBot.create(:cast_member, record: movie, person: person1, character: "Alice")
        FactoryBot.create(:cast_member, record: movie, person: person2, character: "Bob / Old Man")
        cm1.insert_at(2)
        cast_members = CastMembers::Movie.new(movie).cast_members
        expect(cast_members).to eq([
          {person: person2, characters: [
            {character_name: "Bob", count: 0, position: 1},
            {character_name: "Old Man", count: 0, position: 1}
          ]},
          {person: person1, characters: [
            {character_name: "Alice", count: 0, position: 2}
          ]}
        ])
      end
    end
  end
end
