class SeasonRegularsController < ApplicationController
  before_action :require_authentication
  before_action :set_show
  before_action :set_season
  before_action :set_cast_member, only: [:update, :destroy, :move]

  def index
    @table_presenter = Tabulator::CastMembersPresenter.new(@season.season_regulars.includes(:person))
  end

  def create
    parent = params[:add_to_all_seasons] ? @show : @season
    if cast_member_already_assigned_to_show?
      redirect_to show_season_season_regulars_path(@season, show_id: @show), alert: "That cast member has already been assigned as a recurring season regular to this show."
      return
    end

    @cast_member = parent.season_regulars.new(cast_member_params)
    if @cast_member.save
      redirect_to show_season_season_regulars_path(@season, show_id: @show)
    else
      redirect_to show_season_season_regulars_path(@season, show_id: @show), alert: "Could not add that cast member."
    end
  end

  def update
    if @cast_member.update(cast_member_params)
      render json: {success: true}, status: 200
    else
      errors = @cast_member.errors.group_by_attribute.each_pair.map { |field, errors| {field => errors.map(&:full_message)} }
      render json: {success: false, errors:}, status: 422
    end
  end

  def destroy
    @cast_member.destroy
    head :no_content
  end

  def move
    @cast_member.insert_at(params[:position].to_i) if params[:position].present?
    head :ok
  end

  private

  def cast_member_params
    params.expect(cast_member: [:person_id, :character])
  end

  def set_show
    @show = Show.from_slug(params.expect(:show_id))
  end

  def set_season
    @season = @show.seasons.find_by!(number: params.expect(:season_id))
  end

  def set_cast_member
    @cast_member = @season.season_regulars.find(params.expect(:id))
  end

  def cast_member_already_assigned_to_show?
    @show.season_regulars.exists?(person_id: cast_member_params[:person_id])
  end
end
