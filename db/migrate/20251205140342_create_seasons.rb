class CreateSeasons < ActiveRecord::Migration[8.0]
  def change
    create_table :seasons do |t|
      t.references :show, null: false, foreign_key: true
      t.integer :number
      t.string :translated_name, null: false
      t.string :original_name, null: false
      t.string :overview

      t.timestamps
    end

    add_index :seasons, [:show_id, :number], unique: true, name: "index_unique_seasons_number_show"
  end
end
