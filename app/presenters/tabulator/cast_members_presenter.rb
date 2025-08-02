module Tabulator
  class CastMembersPresenter < Base
    def column_defs
      [
        {title: "Person", field: "person", formatter: "image", headerSort: false, editor: false},
        {title: "Character", field: "character", headerSort: false, editor: true},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "cast_member"

    def movable = true

    private

    def to_hash(cast_member)
      {
        id: cast_member.id,
        person: {value: cast_member.person.image_url, label: cast_member.person.translated_name},
        character: cast_member.character
      }
    end
  end
end
