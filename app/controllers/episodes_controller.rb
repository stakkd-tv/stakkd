class EpisodesController < ApplicationController
  before_action :require_authentication, except: [:show, :cast]
  before_action :set_show
  before_action :set_season
  before_action :set_episode, except: [:new, :create]

  def show
    @cast_members = CastMembers::Episode.new(@episode).cast_members
  end

  def new
    number = @season.latest_episode_number + 1
    @episode = @season.episodes.new(number:, translated_name: "Episode #{number}", original_name: "Episode #{number}")
  end

  def edit
  end

  def create
    @episode = @season.episodes.new(episode_params)

    if @episode.save
      redirect_to edit_show_season_episode_path(@episode, season_id: @season, show_id: @show), notice: "Episode was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @episode.update(episode_params)
      redirect_to show_season_episode_path(@episode, season_id: @season, show_id: @show), notice: "Episode was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def backgrounds
  end

  def cast
    @cast_members = CastMembers::Episode.new(@episode).cast_members
    @crew_members = @episode.crew_members.includes(:job, person: {images_attachments: :blob}).group_by { it.job.department }
  end

  private

  def set_show
    @show = Show.from_slug(params.expect(:show_id))
  end

  def set_season
    @season = @show.seasons.find_by!(number: params.expect(:season_id))
  end

  def set_episode
    @episode = @season.episodes.find_by!(number: params.expect(:id))
  end

  def episode_params
    params.expect(episode: [:number, :translated_name, :original_name, :overview, :original_air_date, :episode_type, :runtime, :production_code, :imdb_id])
  end
end
