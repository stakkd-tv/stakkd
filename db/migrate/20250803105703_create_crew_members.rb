class CreateCrewMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :crew_members do |t|
      t.references :record, polymorphic: true, null: false
      t.references :person, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true

      t.timestamps
    end
  end
end
