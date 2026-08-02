require "rails_helper"

module Tabulator
  RSpec.describe FranchiseItemsPresenter, type: :presenter do
    let(:franchise_items) { FactoryBot.create_list(:franchise_item, 1) }
    let(:presenter) { FranchiseItemsPresenter.new(franchise_items) }

    describe "#table_data" do
      it "returns the fields for the franchise itemss" do
        expect(presenter.table_data).to eq([
          {
            id: franchise_items.first.id,
            item: franchise_items.first.record.to_s,
            type: franchise_items.first.record_type,
            date: franchise_items.first.date
          }
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Item", field: "item", sorter: "string", editor: false},
          {title: "Type", field: "type", sorter: "string", editor: false, width: "120", resizable: false},
          {title: "Date", field: "date", sorter: "date", editor: false, width: "120", resizable: false},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "franchise_item"
      end
    end

    describe "#group_by" do
      it "returns true" do
        expect(presenter.group_by).to be_nil
      end
    end
  end
end
