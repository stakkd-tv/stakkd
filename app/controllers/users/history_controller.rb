class Users::HistoryController < Users::BaseController
  before_action :set_scope

  SCOPES = {
    movie: Movie,
    show: Show,
    season: Season,
    episode: Episode
  }.freeze

  PER_PAGE = 50

  def index
    allowed_media_types = ["Movie", "Episode"]
    @hidden_media_types = (params[:hidden_media_types] || []).map(&:humanize)
    media_types = allowed_media_types - @hidden_media_types

    @history_items = @user.history_items
      .where(item_type: media_types)

    apply_media_filter

    @history_items = @history_items
      .includes(item: [:season, :show])
      .order(Arel.sql("consumed_at DESC NULLS LAST"))
      .paginate(page: params[:page], per_page: PER_PAGE)

    @last_date = params[:last_date]&.to_date
    @show_dates = params[:hide_dates] != "true"

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def apply_media_filter
    return unless @scope

    case given_scope
    when :movie
      @history_items = @history_items
        .where(item_type: "Movie", item_id: @scope.id)
    when :episode
      @history_items = @history_items
        .where(item_type: "Episode", item_id: @scope.id)
    when :season
      @history_items = @history_items
        .where(item_type: "Episode")
        .joins("INNER JOIN episodes ON episodes.id = history_items.item_id")
        .where(episodes: {season_id: @scope.id})
    when :show
      @history_items = @history_items
        .where(item_type: "Episode")
        .joins("INNER JOIN episodes ON episodes.id = history_items.item_id")
        .joins("INNER JOIN seasons ON seasons.id = episodes.season_id")
        .where(seasons: {show_id: @scope.id})
    end
  end

  def set_scope
    klass = SCOPES[given_scope]
    scope_id = params[:scope_id]
    if given_scope && klass.nil?
      return redirect_back fallback_location: user_history_index_path(@user), alert: "Scope is not valid"
    end
    return unless given_scope

    @scope = klass.find(scope_id)
  end

  def given_scope = params[:scope]&.downcase&.to_sym
end
