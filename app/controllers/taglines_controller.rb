class TaglinesController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_tagline, only: [:update, :destroy, :move]

  def index
    @table_presenter = Tabulator::TaglinesPresenter.new(@relatable.taglines)
  end

  def create
    @tagline = @relatable.taglines.new(tagline_params)
    if @tagline.save
      redirect_to nested_path_for(relatable: @relatable)
    else
      redirect_to nested_path_for(relatable: @relatable), alert: "Could not add that tagline."
    end
  end

  def update
    if @tagline.update(tagline_params)
      render json: {success: true}, status: 200
    else
      errors = @tagline.errors.group_by_attribute.each_pair.map { |field, errors| {field => errors.map(&:full_message)} }
      render json: {success: false, errors:}, status: 422
    end
  end

  def destroy
    @tagline.destroy
    head :no_content
  end

  def move
    @tagline.insert_at(params[:position].to_i) if params[:position].present?
    head :ok
  end

  private

  def tagline_params
    params.expect(tagline: [:tagline])
  end

  def set_tagline
    @tagline = @relatable.taglines.find(params.expect(:id))
  end
end
