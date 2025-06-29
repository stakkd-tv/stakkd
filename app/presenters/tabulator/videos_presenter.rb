module Tabulator
  class VideosPresenter < Base
    def column_defs
      [
        {title: "", field: "source", headerSort: false, formatter: "html", width: 50, resizable: false},
        {title: "Key", field: "source_key", headerSort: false, width: 125, resizable: false},
        {title: "Title", field: "title", sorter: "string", formatter: "link", formatterParams: {labelField: "name"}, minWidth: 200},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "video"

    def group_by = "type"

    private

    def to_hash(video)
      {
        id: video.id,
        source: "<div class='flex justify-center items-center'><i class='fa-brands #{video.source_icon} text-lg'></i></div>",
        source_key: video.source_key,
        title: video.url,
        name: video.name,
        type: video.type
      }
    end
  end
end
