class ShowsController < ApplicationController
  before_action :require_authentication, except: [:index, :show, :cast]
  before_action :set_show, except: [:index, :new, :create]

  def index
    @show_filter = ::Filters::Shows.new(params)
    @shows = @show_filter.filter.paginate(page: params[:page], per_page: 12)
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

  private

  def set_show
    @show = Show.from_slug(params.expect(:id))
  end

  def show_params
    params.expect(show: [:language_id, :country_id, :homepage, :imdb_id, :original_title, :overview, :status, :translated_title, :type])
  end
end
