class CreateCastMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :cast_members do |t|
      t.references :record, polymorphic: true, null: false
      t.references :person, null: false, foreign_key: true
      t.string :character, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
