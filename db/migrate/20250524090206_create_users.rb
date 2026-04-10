class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :username, null: false
      t.text :biography
      t.boolean :private, null: false, default: false
      t.datetime :confirmed_at
      t.datetime :confirmation_reminder_sent_at
      t.datetime :banned_at
      t.references :banned_by, foreign_key: {to_table: :users}, null: true
      t.string :ban_reason

      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_index :users, "LOWER(username)", unique: true
  end
end
