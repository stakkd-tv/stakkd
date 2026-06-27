class CreateSearchDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :search_documents do |t|
      t.string :original_title
      t.string :translated_title
      t.text :aliases
      t.references :searchable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
