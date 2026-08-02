class CreateFranchises < ActiveRecord::Migration[8.1]
  def change
    create_table :franchises do |t|
      t.string :homepage
      t.string :original_title, null: false
      t.string :translated_title, null: false
      t.string :overview
      t.string :title_kebab, null: false

      t.timestamps
    end
  end
end
