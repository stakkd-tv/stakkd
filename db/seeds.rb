Person.delete_all
Job.delete_all
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

  ||Spoilers work too!|| <- Hover over this!
HEREDOC
User.create(username: "crxssed", email_address: "test@example.com", password: "123456", biography:, confirmed_at: Time.current, profile_picture: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "300x450.png")))
User.create(username: "other_user", email_address: "test2@example.com", password: "123456", confirmed_at: Time.current)
User.create(username: "unconfirmed_user", email_address: "test3@example.com", password: "123456")
User.create(username: "banned_user", email_address: "test4@example.com", password: "123456").ban!(reason: "Spam")
User.create(username: "private_user", email_address: "test5@example.com", password: "123456", private: true)

puts "=== Importing genres ==="
Sync::Genres.new.start
animation = Genre.find_by(name: "Animation")
adventure = Genre.find_by(name: "Adventure")
fantasy = Genre.find_by(name: "Fantasy")
family = Genre.find_by(name: "Family")

puts "=== Importing countries ==="
Sync::Countries.new.start
us = Country.find_by(code: "US")
us_pg = Certification.create!(
  country: us,
  media_type: "Movie",
  code: "PG",
  description: "Parental Guidance",
  position: 1
)

puts "=== Importing languages ==="
Sync::Languages.new.start
english = Language.find_by(code: "en")

puts "=== Creating companies ==="
avatar_studios = Company.create!(
  name: "Avatar Studios",
  description: "In 2021, Nickelodeon founded Avatar Studios, to be led by Michael Dante DiMartino and Bryan Konietzko, co-creators of Avatar: The Last Airbender and The Legend of Korra.",
  homepage: "https://www.avatarstudiosofficial.com/",
  country: us
)

puts "=== Creating people ==="
lauren = Person.create!(
  biography: "Lauren Eve Montgomery (born May 4, 1980) is an American storyboard artist, director, character designer, producer, and writer. She is known for storyboarding the DC Comics animated series and movies.",
  imdb_id: "nm2304017",
  known_for: "directing",
  original_name: "Lauren Montgomery",
  translated_name: "Lauren Montgomery"
)
konietzko = Person.create!(
  biography: "Bryan Joseph Konietzko (born June 1, 1975 or May 26, 1976) is an American animator, writer, producer and director. He and Michael Dante DiMartino are best known as the co-creator and executive producer of the animated series Avatar: The Last Airbender and The Legend of Korra.",
  imdb_id: "nm1665983",
  known_for: "production",
  original_name: "Bryan Konietzko",
  translated_name: "Bryan Konietzko"
)
bautista = Person.create!(
  biography: "David Michael Bautista Jr. (born January 18, 1969) is an American actor and retired professional wrestler. Regarded as one of his generation's most prolific professional wrestlers, he rose to fame for his multiple stints in WWE between 2002 and 2019.",
  imdb_id: "nm1176985",
  known_for: "acting",
  original_name: "Dave Bautista",
  translated_name: "Dave Bautista"
)
director = Job.create!(
  name: "Director",
  department: "Directing"
)
story = Job.create!(
  name: "Story",
  department: "Writing"
)

puts "=== Creating movies ==="
aang_the_last_airbender = Movie.create!(
  translated_title: "Avatar Aang: The Last Airbender",
  original_title: "Avatar Aang: The Last Airbender",
  language: english,
  country: us,
  overview: "Avatar Aang, the world's last Airbender, learns of an ancient power that could save his culture from extinction. With the help of his friends, he embarks on a global quest to find it before it falls into the wrong hands and threatens to upend the peace they sacrificed everything to achieve.",
  status: "released",
  runtime: 99,
  homepage: "https://www.paramountplus.com/movies/video/ALVE01KRF3YJMCEJB92T78193MJ4HP",
  imdb_id: "tt18259538",
  genres: [animation, adventure, fantasy, family],
  companies: [avatar_studios],
  keyword_list: ["martial arts", "extinction", "quest"]
)
AlternativeName.create!(
  country: us,
  name: "Aang: The Last Airbender",
  type: "working title",
  record: aang_the_last_airbender
)
Tagline.create!(
  tagline: "The legacy reawakens.",
  record: aang_the_last_airbender
)
Release.create!(
  movie: aang_the_last_airbender,
  type: "Digital",
  date: Date.new(2026, 7, 25),
  certification: us_pg
)
Uploads::Upload.new(
  record: aang_the_last_airbender,
  field: :posters,
  image: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "aang_movie.png")),
  validator_class: Uploads::Validators::MoviePostersValidator
).validate_and_save!
Uploads::Upload.new(
  record: aang_the_last_airbender,
  field: :backgrounds,
  image: Rack::Test::UploadedFile.new(File.join(Rails.root, "spec", "support", "assets", "aang_movie_bg.png")),
  validator_class: Uploads::Validators::MovieBackgroundsValidator
).validate_and_save!
CrewMember.create!(
  record: aang_the_last_airbender,
  person: lauren,
  job: director
)
CrewMember.create!(
  record: aang_the_last_airbender,
  person: konietzko,
  job: story
)
CastMember.create!(
  record: aang_the_last_airbender,
  person: bautista,
  character: "Tagah (voice)"
)
