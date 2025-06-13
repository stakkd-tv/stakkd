class CreateAlternativeNames < ActiveRecord::Migration[8.0]
  def change
    create_table :alternative_names do |t|
      t.string :name
      t.string :type
      t.references :country, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false

      t.timestamps
    end
  end
end
