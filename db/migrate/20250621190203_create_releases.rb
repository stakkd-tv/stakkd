class CreateReleases < ActiveRecord::Migration[8.0]
  def change
    create_table :releases do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :certification, null: false, foreign_key: true
      t.string :type, null: false
      t.string :note
      t.date :date, null: false

      t.timestamps
    end
  end
end
