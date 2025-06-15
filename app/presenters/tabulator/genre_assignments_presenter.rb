module Tabulator
  class GenreAssignmentsPresenter < Base
    def column_defs
      [
        {title: "Name", field: "name", sorter: "string", editor: false},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "genre_assignment"

    private

    def to_hash(genre_assignment)
      {
        id: genre_assignment.id,
        name: genre_assignment.genre.name
      }
    end
  end
end
