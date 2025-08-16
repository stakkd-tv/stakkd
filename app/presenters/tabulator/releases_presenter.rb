module Tabulator
  class ReleasesPresenter < Base
    def column_defs
      [
        {title: "Date", field: "date", sorter: "date", editor: "date", minWidth: 120, width: 120},
        {title: "Certification", field: "certification_id", sorter: "string", editor: "list", minWidth: 150, width: 150, editorParams: {
          values: Certification.for_movies.includes(:country).order(:position).map { {label: it.code, value: it.id, scope: it.country.id} }
        }},
        {title: "Type", field: "type", sorter: "string", editor: "list", minWidth: 200, width: 200, editorParams: {
          values: Release::TYPES.map { {label: it, value: it} }
        }},
        {title: "Note", field: "note", sorter: "string", editor: true, minWidth: 200},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "release"

    def group_by = "country_id"

    private

    def to_hash(release)
      {
        id: release.id,
        certification_id: {label: release.certification.code, value: release.certification.id, scope: release.certification.country.id},
        type: {label: release.type, value: release.type},
        note: release.note,
        date: release.date.strftime("%d-%m-%Y"),
        country_id: {label: release.certification.country.translated_name, value: release.certification.country.id}
      }
    end
  end
end
