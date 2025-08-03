require "rails_helper"

module Tabulator
  RSpec.describe CrewMembersPresenter, type: :presenter do
    let(:crew_members) { FactoryBot.build_list(:crew_member, 1) }
    let(:presenter) { CrewMembersPresenter.new(crew_members) }

    describe "#table_data" do
      it "returns the fields for the crew members" do
        expect(presenter.table_data).to eq([
          {
            id: crew_members.first.id,
            person: {value: crew_members.first.person.image_url, label: crew_members.first.person.translated_name},
            job_id: {value: crew_members.first.job.id, label: crew_members.first.job.name}
          }
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Person", field: "person", formatter: "image", headerSort: false, editor: false},
          {title: "Job", field: "job_id", headerSort: false, editor: "list", editorParams: {
            values: Job.order(:department, :name).map { {label: _1.name, value: _1.id} }
          }},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "crew_member"
      end
    end

    describe "#movable" do
      it "returns true" do
        expect(presenter.movable).to eq false
      end
    end
  end
end
