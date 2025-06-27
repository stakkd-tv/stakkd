class CompanyAssignmentsController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_company_assignment, only: [:destroy]

  def index
    @table_presenter = Tabulator::CompanyAssignmentsPresenter.new(@relatable.company_assignments.includes(:company).order(company: {name: :asc}))
  end

  def create
    @company_assignment = @relatable.company_assignments.new(company_assignment_params)
    if @company_assignment.save
      redirect_to nested_path_for(relatable: @relatable)
    else
      redirect_to nested_path_for(relatable: @relatable), alert: "Could not add company. You must choose a company from the dropdown and can't assign the same company twice."
    end
  end

  def destroy
    @company_assignment.destroy
    head :no_content
  end

  private

  def company_assignment_params
    params.expect(company_assignment: [:company_id])
  end

  def set_company_assignment
    @company_assignment = @relatable.company_assignments.find(params.expect(:id))
  end
end
