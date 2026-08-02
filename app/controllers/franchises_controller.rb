class FranchisesController < ApplicationController
  before_action :require_authentication, except: [:index, :show]
  before_action :set_movie, except: [:index, :new, :create]

  def index
    @franchise_filter = ::Filters::Franchises.new(params)
    @franchises = @franchise_filter.filter.paginate(page: params[:page], per_page: ApplicationController::GLOBAL_PER_PAGE)
    @filter_params = @franchise_filter.to_params
  end

  def show
    @gallery_presenter = Galleries::Presenter.new(@franchise)
  end

  def new
    @franchise = Franchise.new
  end

  def edit
  end

  def create
    @franchise = Franchise.new(franchise_params)

    if @franchise.save
      redirect_to edit_franchise_path(@franchise), notice: "Franchise was successfully created, you can now add items to it."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
  end

  def posters
  end

  def backgrounds
  end

  def logos
  end

  def items
  end

  private

  def franchise_params
    params.expect(franchise: [:original_title, :translated_title, :overview, :homepage])
  end

  def set_movie
    @franchise = Franchise.includes(franchise_items: :record).from_slug(params.expect(:id))
  end
end
