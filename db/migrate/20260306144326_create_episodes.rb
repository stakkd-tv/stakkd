class CreateEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table :episodes do |t|
      t.references :season, null: false, foreign_key: true
      t.string :translated_name, null: false
      t.string :original_name, null: false
      t.text :overview
      t.date :original_air_date
      t.integer :number, null: false
      t.string :episode_type, null: false, default: Episode::STANDARD
      t.integer :runtime, null: false, default: 0
      t.string :production_code
      t.string :imdb_id

      t.timestamps
    end

    add_index :episodes, [:season_id, :number], unique: true, name: "index_unique_episodes_number_season"
  end
end
