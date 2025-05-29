class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :alias
      t.text :biography
      t.date :dob
      t.date :dod
      t.string :gender, default: "unknown"
      t.string :imdb_id
      t.string :known_for
      t.string :original_name, null: false
      t.string :translated_name, null: false

      t.timestamps
    end
  end
end
