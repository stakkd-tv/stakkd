require "rails_helper"

module CastMembers
  RSpec.describe Show do
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
        @cricket = FactoryBot.create(:person)
        @john = FactoryBot.create(:person)
        CastMember.acts_as_list_no_update do
          FactoryBot.create(:cast_member, person: @winona_ryder, record: @show, character: "Character 1", position: 1)
          @specials.ordered_episodes.each do |episode|
            position = (episode == @episode) ? 4 : 1
            FactoryBot.create(:cast_member, person: @cricket, record: episode, character: "Cricket", position:)
          end
          FactoryBot.create(:cast_member, person: @john, record: @episode, character: "Johnny", position: 1)
          FactoryBot.create(:cast_member, person: @bob, record: @episode, character: "Extra", position: 2)
          FactoryBot.create(:cast_member, person: @winona_ryder, record: @episode, character: "Self", position: 3)
          FactoryBot.create(:cast_member, person: @sean_astin, record: @season1, character: "Character 3", position: 2)
          FactoryBot.create(:cast_member, person: @bob, record: @season1, character: "Character 2", position: 1)
        end
      end

      it "returns the season regulars and guest stars ordered by the position and the amount of episodes they appear in" do
        cast_members = described_class.new(@show).cast_members
        expect(cast_members).to eq([
          {person: @winona_ryder, characters: [
            {character_name: "Character 1", count: 16, position: 1},
            {character_name: "Self", count: 1, position: 20003}
          ]},
          {person: @bob, characters: [
            {character_name: "Extra", count: 1, position: 20002},
            {character_name: "Character 2", count: 8, position: 10001}
          ]},
          {person: @sean_astin, characters: [
            {character_name: "Character 3", count: 8, position: 10002}
          ]},
          {person: @cricket, characters: [
            # Cricket is above John, because she's been in more episodes even though she has a lower position
            {character_name: "Cricket", count: 8, position: 20004}
          ]},
          {person: @john, characters: [
            {character_name: "Johnny", count: 1, position: 20001}
          ]}
        ])
      end
    end
  end
end
