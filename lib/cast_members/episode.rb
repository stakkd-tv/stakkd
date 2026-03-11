module CastMembers
  class Episode < Base
    def initialize(episode)
      super
      @season = episode.season
      @show = episode.show
    end

    private

    def consolidate_cast_members
      @show.season_regulars.includes(person: {images_attachments: :blob}).each do |regular|
        increment_character_count_for(cast_member: regular, increment_by: 0)
      end

      @season.season_regulars.includes(person: {images_attachments: :blob}).each do |regular|
        increment_character_count_for(cast_member: regular, increment_by: 0, depth: 1)
      end

      @object.guest_stars.includes(person: {images_attachments: :blob}).each do |guest_star|
        increment_character_count_for(cast_member: guest_star, increment_by: 0, depth: 2)
      end
    end
  end
end
