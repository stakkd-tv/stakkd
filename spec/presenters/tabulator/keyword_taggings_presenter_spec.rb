require "rails_helper"

module Tabulator
  RSpec.describe KeywordTaggingsPresenter, type: :presenter do
    let(:movie) { FactoryBot.create(:movie, keyword_list: ["Hello there"]) }
    let(:keywords) { movie.keyword_taggings }
    let(:presenter) { KeywordTaggingsPresenter.new(keywords) }

    describe "#table_data" do
      it "returns the fields for the genres" do
        expect(presenter.table_data).to eq([
          {id: keywords.first.id, name: "Hello there"}
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Name", field: "name", sorter: "string", editor: false},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "tagging"
      end
    end
  end
end
