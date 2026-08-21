class CreateStackItems < ActiveRecord::Migration[8.1]
  def change
    create_table :stack_items do |t|
      t.references :stack, null: false, foreign_key: true
      t.references :item, polymorphic: true, null: false
      t.datetime :added_at, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :stack_items, [:stack_id, :item_type, :item_id], unique: true
    add_index :stack_items, [:item_type, :item_id]
    add_index :stack_items, [:stack_id, :position]
  end
end
