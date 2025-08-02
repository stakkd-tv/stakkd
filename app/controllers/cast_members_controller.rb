class CastMembersController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_cast_member, only: [:update, :destroy, :move]

  def index
    @table_presenter = Tabulator::CastMembersPresenter.new(@relatable.cast_members.includes(:person))
  end

  def create
    @cast_member = @relatable.cast_members.new(cast_member_params)
    if @cast_member.save
      redirect_to nested_path_for(relatable: @relatable)
    else
      redirect_to nested_path_for(relatable: @relatable), alert: "Could not add that cast member."
    end
  end

  def update
    if @cast_member.update(cast_member_params)
      render json: {success: true}, status: 200
    else
      errors = @cast_member.errors.group_by_attribute.each_pair.map { |field, errors| {field => errors.map(&:full_message)} }
      render json: {success: false, errors:}, status: 422
    end
  end

  def destroy
    @cast_member.destroy
    head :no_content
  end

  def move
    @cast_member.insert_at(params[:position].to_i) if params[:position].present?
    head :ok
  end

  private

  def cast_member_params
    params.expect(cast_member: [:person_id, :character])
  end

  def set_cast_member
    @cast_member = @relatable.cast_members.find(params.expect(:id))
  end
end
