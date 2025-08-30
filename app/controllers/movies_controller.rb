class MoviesController < ApplicationController
  before_action :require_authentication, except: [:index, :show, :cast]
  before_action :set_movie, except: [:index, :new, :create]

  def index
    movie_filter = ::Filters::Movies.new(params)
    @movies = movie_filter.filter.paginate(page: params[:page], per_page: 12)
    @filter_params = movie_filter.to_params
  end

  def show
    @alternative_names = @movie.alternative_names.includes(:country).group_by(&:country)
    @gallery_presenter = Galleries::Presenter.new(@movie)
    @release_dates_for_country = @movie.release_dates_for_country
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
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @movie.update(movie_params)
      redirect_to @movie, notice: "Movie was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def posters
  end

  def backgrounds
  end

  def logos
  end

  def cast
    @cast_members = @movie.cast_members.includes(:person)
    @crew_members = @movie.crew_members.includes(:person, :job).group_by { it.job.department }
  end

  private

  def set_movie
    @movie = Movie.from_slug(params.expect(:id))
  end

  def movie_params
    params.expect(movie: [:language_id, :country_id, :original_title, :translated_title, :overview, :status, :runtime, :revenue, :budget, :homepage, :imdb_id])
  end
end
