require "rails_helper"

module Tabulator
  RSpec.describe AlternativeNamesPresenter, type: :presenter do
    let(:country) { FactoryBot.create(:country, translated_name: "Test country") }
    let(:alternative_names) { FactoryBot.build_list(:alternative_name, 1, name: "Test name", type: "Test type", country:) }
    let(:presenter) { AlternativeNamesPresenter.new(alternative_names) }

    describe "#table_data" do
      it "returns the fields for the alternative names" do
        expect(presenter.table_data).to eq([
          {id: alternative_names.first.id, name: "Test name", type: "Test type", country_id: {label: "Test country", value: country.id}}
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Name", field: "name", sorter: "string", editor: true},
          {title: "Type", field: "type", sorter: "string", editor: true},
          {title: "Country", field: "country_id", sorter: "string", editor: "list", editorParams: {
            values: [{label: country.translated_name, value: country.id}]
          }}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "alternative_name"
      end
    end
  end
end
