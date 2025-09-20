module Tabulator
  class ContentRatingsPresenter < Base
    def column_defs
      [
        {title: "Certification", field: "certification_id", sorter: "string"},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "content_rating"

    def group_by = "country_id"

    private

    def to_hash(content_rating)
      {
        id: content_rating.id,
        certification_id: content_rating.certification.code,
        country_id: {label: content_rating.certification.country.translated_name, value: content_rating.certification.country.id}
      }
    end
  end
end
