Person.delete_all
Country.delete_all
Language.delete_all
Genre.delete_all
Movie.delete_all
Session.delete_all
User.delete_all
Company.delete_all

puts "=== Creating users ==="
User.create(username: "crxssed", email_address: "test@example.com", password: "123456", confirmed_at: Time.current, profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "300x450.png")))
User.create(username: "other_user", email_address: "test2@example.com", password: "123456", confirmed_at: Time.current)
User.create(username: "unconfirmed_user", email_address: "test3@example.com", password: "123456")
User.create(username: "banned_user", email_address: "test4@example.com", password: "123456").ban!(reason: "Spam")
User.create(username: "private_user", email_address: "test5@example.com", password: "123456", private: true)

puts "=== Importing genres ==="
Sync::Genres.new.start

puts "=== Importing countries ==="
Sync::Countries.new.start

puts "=== Importing languages ==="
Sync::Languages.new.start
