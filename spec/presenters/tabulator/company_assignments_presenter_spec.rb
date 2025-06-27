require "rails_helper"

module Tabulator
  RSpec.describe CompanyAssignmentsPresenter, type: :presenter do
    let(:company) { FactoryBot.create(:company, name: "COMPANY") }
    let(:company_assignments) { FactoryBot.create_list(:company_assignment, 1, company:) }
    let(:presenter) { CompanyAssignmentsPresenter.new(company_assignments) }

    describe "#table_data" do
      it "returns the fields for the companies" do
        expect(presenter.table_data).to eq([
          {id: company_assignments.first.id, company: {value: nil, label: "COMPANY"}}
        ])
      end
    end

    describe "#column_defs" do
      it "returns the column definitions" do
        expect(presenter.column_defs).to eq([
          {title: "Company", field: "company", formatter: "image", headerSort: false, editor: false},
          {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
        ])
      end
    end

    describe "#model_table_name" do
      it "returns the table name" do
        expect(presenter.model_table_name).to eq "company_assignment"
      end
    end
  end
end
