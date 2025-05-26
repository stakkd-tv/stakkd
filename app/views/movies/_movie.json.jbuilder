json.extract! movie, :id, :budget, :homepage, :imdb_id, :original_title, :overview, :release_date, :revenue, :runtime, :status, :tagline, :translated_title, :title_kebab, :created_at, :updated_at
json.url movie_url(movie, format: :json)
