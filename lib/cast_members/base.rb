module CastMembers
  class Base
    def initialize(object)
      @object = object
      @output = []
    end

    def cast_members
      return @output if @output.any?

      consolidate_cast_members

      @output.sort_by do |cast_member|
        character_with_highest_count = cast_member[:characters].max_by { it[:count] }
        character_with_highest_count[:position] - character_with_highest_count[:count]
      end
    end

    private

    def increment_character_count_for(cast_member:, increment_by:, depth: 0)
      existing_person = @output.find { it[:person] == cast_member.person }
      characters = cast_member.character.split(" / ")
      position = (depth * 10_000) + cast_member.position

      if existing_person
        characters.each do |character|
          existing_character_record = existing_person[:characters].find { it[:character_name] == character.strip }

          if existing_character_record
            existing_character_record[:count] += increment_by
          else
            existing_person[:characters] << {character_name: character.strip, count: increment_by, position:}
          end
        end
      else
        @output << {person: cast_member.person, characters: characters.map { {character_name: it.strip, count: increment_by, position:} }}
      end
    end

    def consolidate_cast_members = raise "implement in subclass"
  end
end
