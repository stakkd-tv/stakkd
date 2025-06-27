class ReleasesController < ApplicationController
  before_action :require_authentication
  before_action :set_movie
  before_action :set_release, only: [:update, :destroy]

  def index
    @table_presenter = Tabulator::ReleasesPresenter.new(@movie.releases.includes(certification: :country))
  end

  def create
    @release = @movie.releases.new(release_params)
    if @release.save
      redirect_to movie_releases_path(@movie)
    else
      redirect_to movie_releases_path(@movie), alert: "Release could not be added."
    end
  end

  def update
    if @release.update(release_params)
      render json: {success: true}, status: 200
    else
      errors = @release.errors.group_by_attribute.each_pair.map { |field, errors| {field => errors.map(&:full_message)} }
      render json: {success: false, errors:}, status: 422
    end
  end

  def destroy
    @release.destroy
    head :no_content
  end

  private

  def release_params
    params.expect(release: [:certification_id, :type, :note, :date])
  end

  def set_release
    @release = @movie.releases.find(params.expect(:id))
  end

  def set_movie
    @movie = Movie.from_slug(params.expect(:movie_id))
  end
end
