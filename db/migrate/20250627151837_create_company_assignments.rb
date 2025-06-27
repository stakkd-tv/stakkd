class CreateCompanyAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :company_assignments do |t|
      t.references :company, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false

      t.timestamps
    end

    add_index :company_assignments, [:company_id, :record_type, :record_id], unique: true, name: "index_unique_company_assignments"
  end
end
