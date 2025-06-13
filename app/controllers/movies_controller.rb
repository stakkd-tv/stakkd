class MoviesController < ApplicationController
  before_action :require_authentication, except: [:index, :show]
  before_action :set_movie, except: [:index, :new, :create]

  def index
    @movies = Movie.order(:translated_title)
  end

  def show
    @alternative_names = @movie.alternative_names.includes(:country).group_by(&:country)
  end

  def new
    @movie = Movie.new
  end

  def edit
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to edit_movie_path(@movie), notice: "Movie was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @movie.update(movie_params)
      redirect_to @movie, notice: "Movie was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def posters
  end

  def backgrounds
  end

  def logos
  end

  private

  def set_movie
    @movie = Movie.from_slug(params.expect(:id))
  end

  def movie_params
    params.expect(movie: [:language_id, :country_id, :original_title, :translated_title, :overview, :status, :runtime, :revenue, :budget, :homepage, :imdb_id])
  end
end
