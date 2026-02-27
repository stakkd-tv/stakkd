class SeasonsController < ApplicationController
  before_action :require_authentication, except: [:show]
  before_action :set_show
  before_action :set_season, except: [:new, :create]

  def show
    @gallery_presenter = Galleries::Presenter.new(@season)
  end

  def new
    @season = Season.new
  end

  def edit
  end

  def create
    render :new, status: :unprocessable_content if season_params[:number] == 0

    @season = @show.seasons.new(season_params)

    if @season.save
      redirect_to edit_show_season_path(@season, show_id: @show), notice: "Season was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @season.update(season_params)
      redirect_to show_season_path(@season, show_id: @show), notice: "Season was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_show
    @show = Show.from_slug(params.expect(:show_id))
  end

  def set_season
    @season = @show.seasons.find_by!(number: params.expect(:id))
  end

  def season_params
    params.expect(season: [:number, :translated_name, :original_name, :overview])
  end
end
