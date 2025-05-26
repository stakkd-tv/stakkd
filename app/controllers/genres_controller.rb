class GenresController < ApplicationController
  def index
    @genres = Genre.all.order(:name)
  end
end
