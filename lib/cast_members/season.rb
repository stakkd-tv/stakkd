module CastMembers
  class Season < Base
    def initialize(season)
      super
      @show = season.show
    end

    private

    def consolidate_cast_members
      return @output if @output.any?

      episodes = @object.episodes.includes(guest_stars: :person).to_a

      @show.season_regulars.includes(:person).each do |regular|
        increment_character_count_for(cast_member: regular, increment_by: episodes.size)
      end

      @object.season_regulars.includes(:person).each do |regular|
        increment_character_count_for(cast_member: regular, increment_by: episodes.size, depth: 1)
      end

      episodes.each do |episode|
        episode.guest_stars.each do |guest_star|
          increment_character_count_for(cast_member: guest_star, increment_by: 1, depth: 2)
        end
      end

      @output
    end
  end
end
