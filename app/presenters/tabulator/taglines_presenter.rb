module Tabulator
  class TaglinesPresenter < Base
    def column_defs
      [
        {title: "Tagline", field: "tagline", headerSort: false, editor: true},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "tagline"

    def movable = true

    private

    def to_hash(tagline)
      {
        id: tagline.id,
        tagline: tagline.tagline,
        position: tagline.position
      }
    end
  end
end
