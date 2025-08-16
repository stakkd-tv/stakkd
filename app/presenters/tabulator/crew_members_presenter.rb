module Tabulator
  class CrewMembersPresenter < Base
    def column_defs
      [
        {title: "Person", field: "person", formatter: "image", headerSort: false, editor: false},
        {title: "Job", field: "job_id", headerSort: false, editor: "list", editorParams: {
          values: Job.order(:department, :name).map { {label: it.name, value: it.id} }
        }},
        {title: "", field: "actions", headerSort: false, formatter: "buttonCross", resizable: false, width: "0"}
      ]
    end

    def model_table_name = "crew_member"

    private

    def to_hash(crew_member)
      {
        id: crew_member.id,
        person: {value: crew_member.person.image_url, label: crew_member.person.translated_name},
        job_id: {value: crew_member.job.id, label: crew_member.job.name}
      }
    end
  end
end
