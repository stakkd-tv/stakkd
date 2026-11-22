class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, index: false, foreign_key: {on_delete: :cascade}
      t.references :item, polymorphic: true, null: false
      t.integer :score, null: false
      t.timestamps

      t.index [:user_id, :item_type, :item_id], unique: true
      t.check_constraint "score BETWEEN 1 AND 10", name: "ratings_valid_score"
      t.check_constraint "item_type IN ('Movie', 'Show', 'Season', 'Episode')", name: "ratings_supported_types"
    end
  end
end
