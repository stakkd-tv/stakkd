require "rails_helper"

module CastMembers
  RSpec.describe Episode do
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

        @winona_ryder = FactoryBot.create(:person, translated_name: "Winona Ryder")
        @bob = FactoryBot.create(:person, translated_name: "Bob")
        @sean_astin = FactoryBot.create(:person, translated_name: "Sean Astin")
        CastMember.acts_as_list_no_update do # TODO: Figure out why this is needed for this spec but not others. CI fails without it.
          FactoryBot.create(:cast_member, person: @winona_ryder, record: @show, character: "Character 1", position: 1)
          FactoryBot.create(:cast_member, person: @bob, record: @specials, character: "Character 2 / Additional Voices", position: 1)
          FactoryBot.create(:cast_member, person: @bob, record: @episode, character: "Extra", position: 1)
          FactoryBot.create(:cast_member, person: @winona_ryder, record: @episode, character: "Self", position: 2)
          FactoryBot.create(:cast_member, person: @sean_astin, record: @season1, character: "Character 3", position: 1)
          FactoryBot.create(:cast_member, person: @bob, record: @season1, character: "Character 2", position: 2)
        end
      end

      it "returns the season regulars and guest stars ordered by the position" do
        cast_members = described_class.new(@episode).cast_members
        expect(cast_members).to eq([
          {person: @winona_ryder, characters: [
            {character_name: "Character 1", count: 0, position: 1},
            {character_name: "Self", count: 0, position: 20002}
          ]},
          {person: @bob, characters: [
            {character_name: "Character 2", count: 0, position: 10001},
            {character_name: "Additional Voices", count: 0, position: 10001},
            {character_name: "Extra", count: 0, position: 20001}
          ]}
        ])

        cast_members = described_class.new(@episode.next_episode).cast_members
        expect(cast_members).to eq([
          {person: @winona_ryder, characters: [
            {character_name: "Character 1", count: 0, position: 1}
          ]},
          {person: @bob, characters: [
            {character_name: "Character 2", count: 0, position: 10001},
            {character_name: "Additional Voices", count: 0, position: 10001}
            # Extra is not included
          ]}
        ])
      end
    end
  end
end
