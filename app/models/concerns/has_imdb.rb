module HasImdb
  extend ActiveSupport::Concern

  def imdb_url = "https://www.imdb.com/title/#{imdb_id}/"
end
