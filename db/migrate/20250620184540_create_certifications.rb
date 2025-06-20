class CreateCertifications < ActiveRecord::Migration[8.0]
  def change
    create_table :certifications do |t|
      t.string :media_type, null: false
      t.references :country, null: false, foreign_key: true
      t.string :code, null: false
      t.string :description, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
