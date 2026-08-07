class CreateHistoryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :history_items do |t|
      t.datetime :consumed_at
      t.references :user, null: false, foreign_key: true
      t.references :item, polymorphic: true, null: false

      t.timestamps
    end

    add_index :history_items, [:user_id, :item_type, :item_id]
    add_index :history_items, [:user_id, :consumed_at]
    add_index :history_items, [:item_type, :item_id, :consumed_at]
  end
end
