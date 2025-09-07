class ShowsController < ApplicationController
  before_action :require_authentication, except: [:index, :show]
  before_action :set_show, except: [:index, :new, :create]

  def index
    @shows = Show.all
  end

  def show
    @alternative_names = @show.alternative_names.includes(:country).group_by(&:country)
    @gallery_presenter = Galleries::Presenter.new(@show)
  end

  def new
    @show = Show.new
  end

  def edit
  end

  def create
    @show = Show.new(show_params)

    if @show.save
      redirect_to edit_show_path(@show), notice: "Show was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @show.update(show_params)
      redirect_to @show, notice: "Show was successfully updated."
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

  private

  def set_show
    @show = Show.from_slug(params.expect(:id))
  end

  def show_params
    params.expect(show: [:language_id, :country_id, :homepage, :imdb_id, :original_title, :overview, :runtime, :status, :translated_title, :type])
  end
end
