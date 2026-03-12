class CompaniesController < ApplicationController
  before_action :require_authentication, except: [:index, :show]
  before_action :set_company, only: [:show, :edit, :update, :logos]

  PER_PAGE = 10

  def index
    @companies = Company.all
  end

  def show
    @gallery_presenter = Galleries::Presenter.new(@company)
    @company_assignments = @company.company_assignments.includes(:record).paginate(page: params[:page], per_page: PER_PAGE)
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to edit_company_path(@company), notice: "Company was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: "Company was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def logos
  end

  private

  def set_company
    @company = Company.find(params.expect(:id))
  end

  def company_params
    params.expect(company: [:description, :homepage, :name, :country_id])
  end
end
