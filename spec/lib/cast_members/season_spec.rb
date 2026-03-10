require "rails_helper"

module CastMembers
  RSpec.describe Season do
    describe "#cast_members" do
      before do
        @show = FactoryBot.create(:show)
        @specials = @show.ordered_seasons.first
        8.times do |number|
          FactoryBot.create(:episode, season: @specials, number: number + 1)
        end
        @season1 = FactoryBot.create(:season, show: @show, number: 1)
        8.times do |number|
          FactoryBot.create(:episode, season: @season1, number: number + 1)
        end
        @episode = @specials.ordered_episodes.first

        @winona_ryder = FactoryBot.create(:person)
        @bob = FactoryBot.create(:person)
        @sean_astin = FactoryBot.create(:person)
        FactoryBot.create(:cast_member, person: @winona_ryder, record: @show, character: "Character 1")
        FactoryBot.create(:cast_member, person: @bob, record: @specials, character: "Character 2 / Additional Voices")
        FactoryBot.create(:cast_member, person: @winona_ryder, record: @episode, character: "Self")
        FactoryBot.create(:cast_member, person: @bob, record: @episode, character: "Extra")
        FactoryBot.create(:cast_member, person: @sean_astin, record: @season1, character: "Character 3").insert_at(1)
        FactoryBot.create(:cast_member, person: @bob, record: @season1, character: "Character 2").insert_at(2)
      end

      it "returns the season regulars and guest stars ordered by the position" do
        cast_members = described_class.new(@specials).cast_members
        expect(cast_members).to eq([
          {person: @winona_ryder, characters: [
            {character_name: "Character 1", count: 8, position: 1},
            {character_name: "Self", count: 1, position: 20002}
          ]},
          {person: @bob, characters: [
            {character_name: "Character 2", count: 8, position: 10001},
            {character_name: "Additional Voices", count: 8, position: 10001},
            {character_name: "Extra", count: 1, position: 20001}
          ]}
        ])

        cast_members = described_class.new(@season1).cast_members
        expect(cast_members).to eq([
          {person: @winona_ryder, characters: [
            {character_name: "Character 1", count: 8, position: 1}
          ]},
          {person: @sean_astin, characters: [
            {character_name: "Character 3", count: 8, position: 10001}
          ]},
          {person: @bob, characters: [
            {character_name: "Character 2", count: 8, position: 10002}
          ]}
        ])
      end
    end
  end
end
