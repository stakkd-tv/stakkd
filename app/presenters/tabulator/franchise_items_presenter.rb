module Tabulator
  class FranchiseItemsPresenter < Base
    def column_defs
      [
        {title: "Item", field: "item", sorter: "string", editor: false},
        {title: "Type", field: "type", sorter: "string", editor: false, width: "120", resizable: false},
        {title: "Date", field: "date", sorter: "date", editor: false, width: "120", resizable: false},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "franchise_item"

    private

    def to_hash(franchise_item)
      {
        id: franchise_item.id,
        item: franchise_item.record.to_s,
        type: franchise_item.record_type,
        date: franchise_item.date
      }
    end
  end
end
