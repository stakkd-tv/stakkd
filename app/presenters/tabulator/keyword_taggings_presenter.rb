module Tabulator
  class KeywordTaggingsPresenter < Base
    def column_defs
      [
        {title: "Name", field: "name", sorter: "string", editor: false},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "tagging"

    private

    def to_hash(keyword_tagging)
      {
        id: keyword_tagging.id,
        name: keyword_tagging.tag.name
      }
    end
  end
end
