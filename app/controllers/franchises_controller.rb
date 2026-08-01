class FranchisesController < ApplicationController
  before_action :require_authentication, except: [:index, :show]
  before_action :set_movie, except: [:index, :new, :create]

  def index
    @franchise_filter = ::Filters::Franchises.new(params)
    @franchises = @franchise_filter.filter.paginate(page: params[:page], per_page: ApplicationController::GLOBAL_PER_PAGE)
    @filter_params = @franchise_filter.to_params
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def posters
  end

  def backgrounds
  end

  def logos
  end

  private

  def set_movie
    @franchise = Franchise.includes(franchise_items: :record).from_slug(params.expect(:id))
  end
end
