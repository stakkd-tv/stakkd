class Users::CollectionsController < Users::BaseController
  before_action :set_collection_query
  before_action :set_show, only: [:show, :season]

  PER_PAGE = 24
  EPISODES_PER_PAGE = 30

  def index
    @groups, @next_page = @collection_query.fetch(page: params[:page], per_page: PER_PAGE)
    @formats = CollectionFormat.available_to(@user).order(:name)
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @active_format_names = CollectionFormat.available_to(@user)
      .where(id: @collection_query.format_ids.excluding("none")).order(:name).pluck(:name)
    @active_format_names << "No format specified" if @collection_query.format_ids.include?("none")
    @seasons = @collection_query.seasons_for(@show).includes(:show)
    @owned_counts = @collection_query.entries_for(@show).group("episodes.season_id").count
    if current_user == @user
      @removal_counts = @collection_query.removal_counts_for(@show)
      @regular_removal_count = @removal_counts.except(*@show.seasons.where(number: 0).ids).values.sum
    end
    @eligible_counts = Episode.released.where(season_id: @seasons.select(:id)).group(:season_id).count
  end

  def season
    @season = @collection_query.seasons_for(@show).find_by!(number: params[:season_number])
    @entries = @collection_query.entries_for(@show).where(episodes: {season_id: @season.id})
      .includes(:formats, item: [:season, :show])
      .order("episodes.number ASC, collection_items.id ASC")
      .paginate(page: params[:page], per_page: EPISODES_PER_PAGE)
  end

  private

  def set_collection_query
    @collection_query = Collections::Query.new(@user, params)
  end

  def set_show
    @show = Show.from_slug(params[:show_id])
    return if @collection_query.entries_for(@show).exists?

    if action_name == "show" && current_user == @user
      redirect_to user_collection_path(@user, **@collection_query.to_params)
    else
      not_found
    end
  end
end
