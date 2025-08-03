class CreateCrewMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :crew_members do |t|
      t.references :record, polymorphic: true, null: false
      t.references :person, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true

      t.timestamps
    end

    add_index :crew_members, [:person_id, :record_type, :record_id], unique: true, name: "index_unique_crew_members"
  end
end
