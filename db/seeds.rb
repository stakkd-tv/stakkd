Person.delete_all
Country.delete_all
Language.delete_all
Genre.delete_all
Movie.delete_all
Session.delete_all
User.delete_all
Company.delete_all

puts "=== Creating users ==="
User.create(username: "testies", email_address: "test@example.com", password: "123456")

puts "=== Importing genres ==="
Sync::Genres.new.start

puts "=== Importing countries ==="
Sync::Countries.new.start

puts "=== Importing languages ==="
Sync::Languages.new.start

puts "=== Creating companies ==="
FactoryBot.create(:company, country: Country.first)
