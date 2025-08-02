require "rails_helper"

module Tabulator
  RSpec.describe CastMembersPresenter, type: :presenter do
    let(:cast_members) { FactoryBot.build_list(:cast_member, 1, character: "Char name") }
    let(:presenter) { CastMembersPresenter.new(cast_members) }

    describe "#table_data" do
      it "returns the fields for the cast members" do
        expect(presenter.table_data).to eq([
          {
            id: cast_members.first.id,
            person: {value: cast_members.first.person.image_url, label: cast_members.first.person.translated_name},
            character: cast_members.first.character
          }
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Person", field: "person", formatter: "image", headerSort: false, editor: false},
          {title: "Character", field: "character", headerSort: false, editor: true},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "cast_member"
      end
    end

    describe "#movable" do
      it "returns true" do
        expect(presenter.movable).to eq true
      end
    end
  end
end
