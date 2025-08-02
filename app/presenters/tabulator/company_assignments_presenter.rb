module Tabulator
  class CompanyAssignmentsPresenter < Base
    def column_defs
      [
        {title: "Company", field: "company", formatter: "image", headerSort: false, editor: false},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "company_assignment"

    private

    def to_hash(company_assignment)
      {
        id: company_assignment.id,
        company: {value: company_assignment.company.logo_url, label: company_assignment.company.name}
      }
    end
  end
end
