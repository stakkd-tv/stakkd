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


puts "=== Creating companies ==="
Company.create(name: "testworks", homepage: "https://testworks.com", description: "A small company founded in the Poortuguese city of Sugoma.")

puts "=== Importing genres ==="
Sync::Genres.new.start

puts "=== Importing countries ==="
Sync::Countries.new.start

puts "=== Importing languages ==="
Sync::Languages.new.start
