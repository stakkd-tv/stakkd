class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos do |t|
      t.string :name
      t.string :source_key, null: false
      t.string :source, null: false
      t.string :type, null: false
      t.string :thumbnail_url
      t.references :record, polymorphic: true, null: false

      t.timestamps
    end
  end
end
