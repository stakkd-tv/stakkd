class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.references :language
      t.references :country
      t.string :original_title, null: false
      t.string :translated_title, null: false
      t.text :overview
      t.string :status, null: false, default: "in production"
      t.integer :runtime, null: false, default: 0
      t.decimal :revenue, null: false, default: 0
      t.decimal :budget, null: false, default: 0
      t.string :homepage

      t.string :imdb_id
      t.string :title_kebab, null: false

      t.timestamps
    end
  end
end
