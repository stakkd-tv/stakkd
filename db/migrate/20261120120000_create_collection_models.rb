class CreateCollectionModels < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item, polymorphic: true, null: false
      t.timestamps
    end
    add_index :collection_items, [:user_id, :item_type, :item_id], unique: true
    add_check_constraint :collection_items, "item_type IN ('Movie', 'Episode')", name: "collection_items_supported_types"

    create_table :collection_formats do |t|
      t.references :user, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.timestamps
    end
    add_index :collection_formats, :normalized_name, unique: true, where: "user_id IS NULL", name: "collection_formats_unique_common_name"
    add_index :collection_formats, [:user_id, :normalized_name], unique: true, where: "user_id IS NOT NULL", name: "collection_formats_unique_custom_name"
    add_check_constraint :collection_formats, "length(trim(name)) > 0 AND length(trim(normalized_name)) > 0", name: "collection_formats_valid_name"

    create_table :collection_item_formats do |t|
      t.references :collection_item, null: false, foreign_key: {on_delete: :cascade}
      t.references :collection_format, null: false, foreign_key: true
      t.timestamps
    end
    add_index :collection_item_formats, [:collection_item_id, :collection_format_id], unique: true, name: "collection_item_formats_unique_assignment"
  end
end
