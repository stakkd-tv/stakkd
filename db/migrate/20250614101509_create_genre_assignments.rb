class CreateGenreAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :genre_assignments do |t|
      t.references :genre, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false

      t.timestamps
    end

    add_index :genre_assignments, [:genre_id, :record_type, :record_id], unique: true, name: "index_unique_genre_assignments"
  end
end
