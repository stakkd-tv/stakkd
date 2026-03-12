module HasImdb
  extend ActiveSupport::Concern

  def imdb_url
    return nil if imdb_id.blank?
    name_title = imdb_id.start_with?("tt") ? "title" : "name"
    "https://www.imdb.com/#{name_title}/#{imdb_id}/"
  end
end
