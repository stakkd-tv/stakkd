class AlternativeNamesController < ApplicationController
  before_action :require_authentication
  before_action :set_alternative_name, only: [:update]

  def create
    @alternative_name = AlternativeName.new(alternative_name_params)
    if @alternative_name.save
      render json: {success: true}, status: 200
    else
      render json: {success: false}, status: 422
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
    @alternative_name = AlternativeName.find(params.expect(:id))
  end
end
