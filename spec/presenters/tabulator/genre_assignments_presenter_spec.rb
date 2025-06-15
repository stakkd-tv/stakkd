require "rails_helper"

module Tabulator
  RSpec.describe GenreAssignmentsPresenter, type: :presenter do
    let(:genre) { FactoryBot.create(:genre, name: "Action") }
    let(:genre_assignments) { FactoryBot.create_list(:genre_assignment, 1, genre:) }
    let(:presenter) { GenreAssignmentsPresenter.new(genre_assignments) }

    describe "#table_data" do
      it "returns the fields for the genres" do
        expect(presenter.table_data).to eq([
          {id: genre_assignments.first.id, name: "Action"}
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
        expect(presenter.model_table_name).to eq "genre_assignment"
      end
    end
  end
end
