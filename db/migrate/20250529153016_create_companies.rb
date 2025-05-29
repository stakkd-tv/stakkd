class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :description
      t.string :homepage
      t.string :name

      t.timestamps
    end
  end
end
