module CastMembers
  class Show < Base
    def initialize(show)
      super
      @seasons = @object.seasons.includes(season_regulars: {person: {images_attachments: :blob}}, episodes: {guest_stars: {person: {images_attachments: :blob}}}).to_a
    end

    private

    def consolidate_cast_members
      episodes_count = @seasons.flat_map { it.episodes }.size

      @object.season_regulars.includes(person: {images_attachments: :blob}).each do |regular|
        increment_character_count_for(cast_member: regular, increment_by: episodes_count)
      end

      @seasons.each do |season|
        season.season_regulars.each do |regular|
          increment_character_count_for(cast_member: regular, increment_by: season.episodes.size, depth: 1)
        end

        season.episodes.each do |episode|
          episode.guest_stars.each do |guest_star|
            increment_character_count_for(cast_member: guest_star, increment_by: 1, depth: 2)
          end
        end
      end
    end
  end
end
