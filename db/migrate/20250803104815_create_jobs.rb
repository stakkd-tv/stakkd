class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :department, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
