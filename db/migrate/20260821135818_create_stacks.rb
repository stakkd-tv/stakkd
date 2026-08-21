class CreateStacks < ActiveRecord::Migration[8.1]
  def change
    create_table :stacks do |t|
      t.references :user, null: true, foreign_key: true
      t.string :type, null: false, default: "standard"
      t.string :name, null: false
      t.string :sorting_method, null: false, default: "added_at"
      t.boolean :private, null: false, default: false

      t.timestamps
    end

    add_index :stacks, [:user_id, :type]
  end
end
