class ShowsController < ApplicationController
  include Actions::History
  include Actions::Stacks

  before_action :require_authentication, except: [:index, :show, :cast, :poster]
  before_action :set_show, except: [:index, :new, :create]

  def index
    @show_filter = ::Filters::Shows.new(params)
    @shows = @show_filter.filter.paginate(page: params[:page], per_page: ApplicationController::GLOBAL_PER_PAGE)
    @filter_params = @show_filter.to_params

    @tags = ActsAsTaggableOn::Tag
      .joins(:taggings)
      .where("taggings.context = ?", "keywords")
      .distinct
      .order(taggings_count: :desc)
      .limit(200)
  end

  def show
    @alternative_names = @show.alternative_names.includes(:country).group_by(&:country)
    @gallery_presenter = Galleries::Presenter.new(@show)
    @cast_members = CastMembers::Show.new(@show).cast_members
    @watch_status = @show.status_for(current_user)
    @season_watch_statuses = Manage::History.new(current_user).statuses_for(@show.ordered_seasons)
    @stacks_with_previews, @stacks_next_page = @show.stacks_with_previews
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

  def cast
    @cast_members = CastMembers::Show.new(@show).cast_members
    @crew_members = @show.crew_members.includes(:job, person: {images_attachments: :blob}).group_by { it.job.department }
  end

  def poster
    poster = @show.poster(variant: :thumb)

    if poster.is_a?(String)
      path = Rails.root.join("app/assets/images", poster)
      return send_file path, disposition: :inline
    end

    redirect_to url_for(poster)
  end

  private

  def set_show
    @show = Show.includes(
      :seasons_without_specials, :ordered_seasons, :taglines, :videos,
      :keywords, :season_regulars, :genres, :companies, :franchise
    ).from_slug(params.expect(:id))
  end

  def record = @show

  def show_params
    params.expect(show: [:language_id, :country_id, :homepage, :imdb_id, :original_title, :overview, :status, :translated_title, :type])
  end
end
