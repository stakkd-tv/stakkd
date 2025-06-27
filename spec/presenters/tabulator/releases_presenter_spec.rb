require "rails_helper"

module Tabulator
  RSpec.describe ReleasesPresenter, type: :presenter do
    let(:cert) { FactoryBot.create(:certification, code: "ABC", country: FactoryBot.create(:country), media_type: "Movie") }
    let(:releases) { FactoryBot.create_list(:release, 1, certification: cert) }
    let(:presenter) { ReleasesPresenter.new(releases) }

    describe "#table_data" do
      it "returns the fields for the releases" do
        expect(presenter.table_data).to eq([
          {
            id: releases.first.id,
            certification_id: {label: releases.first.certification.code, value: releases.first.certification.id, scope: releases.first.certification.country.id},
            type: {label: releases.first.type, value: releases.first.type},
            note: releases.first.note,
            date: releases.first.date.strftime("%d-%m-%Y"),
            country_id: {label: releases.first.certification.country.translated_name, value: releases.first.certification.country.id}
          }
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        FactoryBot.create(:certification, code: "ABC", country: FactoryBot.create(:country), media_type: "Show")
        expect(presenter.column_defs).to eq([
          {title: "Date", field: "date", sorter: "date", editor: "date", minWidth: 120, width: 120},
          {title: "Certification", field: "certification_id", sorter: "string", editor: "list", minWidth: 150, width: 150, editorParams: {
            values: [{label: cert.code, value: cert.id, scope: cert.country.id}]
          }},
          {title: "Type", field: "type", sorter: "string", editor: "list", minWidth: 200, width: 200, editorParams: {
            values: Release::TYPES.map { {label: _1, value: _1} }
          }},
          {title: "Note", field: "note", sorter: "string", editor: true, minWidth: 200},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "release"
      end
    end

    describe "#group_by" do
      it "returns true" do
        expect(presenter.group_by).to eq "country_id"
      end
    end
  end
end
