module Tabulator
  class AlternativeNamesPresenter < Base
    def column_defs
      [
        {title: "Name", field: "name", sorter: "string", editor: true},
        {title: "Type", field: "type", sorter: "string", editor: true},
        {title: "Country", field: "country_id", sorter: "string", editor: "list", editorParams: {
          values: Country.order(:translated_name).map { {label: _1.translated_name, value: _1.id} }
        }}
      ]
    end

    def model_table_name = "alternative_name"

    private

    def to_hash(alternative_name)
      {
        id: alternative_name.id,
        name: alternative_name.name,
        type: alternative_name.type,
        country_id: {label: alternative_name.country.translated_name, value: alternative_name.country.id}
      }
    end
  end
end
