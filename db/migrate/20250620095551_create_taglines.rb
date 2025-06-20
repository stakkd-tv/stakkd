class CreateTaglines < ActiveRecord::Migration[8.0]
  def change
    create_table :taglines do |t|
      t.string :tagline, null: false
      t.references :record, polymorphic: true, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
