class CreateShows < ActiveRecord::Migration[8.0]
  def change
    create_table :shows do |t|
      t.references :language, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true
      t.string :homepage
      t.string :imdb_id
      t.string :original_title, null: false
      t.string :overview
      t.string :status, null: false
      t.string :translated_title, null: false
      t.string :title_kebab
      t.string :type, null: false

      t.timestamps
    end
  end
end
