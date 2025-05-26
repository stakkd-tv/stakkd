class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.decimal :budget
      t.string :homepage
      t.string :imdb_id
      t.string :original_title
      t.string :overview
      t.date :release_date
      t.decimal :revenue
      t.integer :runtime
      t.string :status
      t.string :tagline
      t.string :translated_title
      t.string :title_kebab

      t.timestamps
    end
  end
end
