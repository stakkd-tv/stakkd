class CreateLanguages < ActiveRecord::Migration[8.0]
  def change
    create_table :languages do |t|
      t.string :code
      t.string :translated_name
      t.string :original_name

      t.timestamps
    end
    add_index :languages, :code, unique: true
  end
end
