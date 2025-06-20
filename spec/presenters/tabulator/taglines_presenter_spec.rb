require "rails_helper"

module Tabulator
  RSpec.describe TaglinesPresenter, type: :presenter do
    let(:taglines) { FactoryBot.create_list(:tagline, 1, tagline: "Test tagline") }
    let(:presenter) { TaglinesPresenter.new(taglines) }

    describe "#table_data" do
      it "returns the fields for the taglines" do
        expect(presenter.table_data).to eq([
          {id: taglines.first.id, tagline: "Test tagline", position: taglines.first.position}
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Tagline", field: "tagline", headerSort: false, editor: true},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "tagline"
      end
    end

    describe "#movable" do
      it "returns true" do
        expect(presenter.movable).to be true
      end
    end
  end
end
