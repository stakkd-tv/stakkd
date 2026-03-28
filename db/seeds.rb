Person.delete_all
Country.delete_all
Language.delete_all
Genre.delete_all
Movie.delete_all
Session.delete_all
User.delete_all
Company.delete_all

puts "=== Creating users ==="
biography = <<~HEREDOC
  # Markdown Rendering

  Stakkd supports markdown rendering for user biographys

  # Headings
  # h1
  ## h2
  ### h3
  #### h4
  ##### h5
  ###### h6

  With markdown, you can format text like *this* and like **this**. [Links are also supported!](https://github.com/stakkd-tv)

  ... and so are images!
  ![stakkd](https://github.com/stakkd-tv.png)

  > YOU WERE THE CHOSEN ONE!
  > - Obi-wan Kenobi

  * unordered
  * lists
  * are
  * great!

  ---

  1. ordered
  2. ones
  3. are
  4. great
  5. too!

  ```ruby
  # Want to show off some code?
  puts "Hello, markdown!"
  ```

  <center>
  	<h3>Certain HTML elements work too :)</h3>
  </center>
  <script>alert("but no malicious ones!")</script>
HEREDOC
User.create(username: "crxssed", email_address: "test@example.com", password: "123456", biography:, confirmed_at: Time.current, profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "300x450.png")))
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
