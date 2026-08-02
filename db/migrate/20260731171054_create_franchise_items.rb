class CreateFranchiseItems < ActiveRecord::Migration[8.1]
  def change
    create_table :franchise_items do |t|
      t.references :franchise, null: false, foreign_key: true
      t.references :record, polymorphic: true, null: false
      t.date :date

      t.timestamps
    end

    add_index :franchise_items, [:record_type, :record_id], unique: true, name: "index_unique_franchise_items"
  end
end
