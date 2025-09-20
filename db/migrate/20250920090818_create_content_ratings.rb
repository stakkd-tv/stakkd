class CreateContentRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :content_ratings do |t|
      t.references :show, null: false, foreign_key: true
      t.references :certification, null: false, foreign_key: true

      t.timestamps
    end

    add_index :content_ratings, [:show_id, :certification_id], unique: true, name: "index_unique_content_ratings"
  end
end
