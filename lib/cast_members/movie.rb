module CastMembers
  class Movie < Base
    private

    def consolidate_cast_members
      @object.cast_members.includes(:person).each do |cast_member|
        increment_character_count_for(cast_member:, increment_by: 0)
      end
    end
  end
end
