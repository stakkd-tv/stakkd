class AlternativeNamesController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_alternative_name, only: [:update]

  def index
    @table_presenter = Tabulator::AlternativeNamesPresenter.new(@relatable.alternative_names.order(id: :asc))
  end

  def create
    @alternative_name = @relatable.alternative_names.new(alternative_name_params)
    if @alternative_name.save
      redirect_to nested_path_for(relatable: @relatable)
    else
      redirect_to nested_path_for(relatable: @relatable), alert: "Could not add that name. A name and country must be specified."
    end
  end

  def update
    if @alternative_name.update(alternative_name_params)
      render json: {success: true}, status: 200
    else
      errors = @alternative_name.errors.group_by_attribute.each_pair.map { |field, errors| {field => errors.map(&:full_message)} }
      render json: {success: false, errors:}, status: 422
    end
  end

  private

  def alternative_name_params
    params.expect(alternative_name: [:name, :type, :country_id])
  end

  def set_alternative_name
    @alternative_name = @relatable.alternative_names.find(params.expect(:id))
  end
end
