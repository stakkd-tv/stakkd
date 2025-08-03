class CrewMembersController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_crew_member, only: [:update, :destroy]

  def index
    @table_presenter = Tabulator::CrewMembersPresenter.new(@relatable.crew_members.includes(:person, :job))
  end

  def create
    @crew_member = @relatable.crew_members.new(crew_member_params)
    if @crew_member.save
      redirect_to nested_path_for(relatable: @relatable)
    else
      redirect_to nested_path_for(relatable: @relatable), alert: "Could not add that crew member."
    end
  end

  def update
    if @crew_member.update(crew_member_params)
      render json: {success: true}, status: 200
    else
      errors = @crew_member.errors.group_by_attribute.each_pair.map { |field, errors| {field => errors.map(&:full_message)} }
      render json: {success: false, errors:}, status: 422
    end
  end

  def destroy
    @crew_member.destroy
    head :no_content
  end

  private

  def crew_member_params
    params.expect(crew_member: [:person_id, :job_id])
  end

  def set_crew_member
    @crew_member = @relatable.crew_members.find(params.expect(:id))
  end
end
