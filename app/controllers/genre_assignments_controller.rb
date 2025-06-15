class GenreAssignmentsController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_genre_assignment, only: [:destroy]

  def index
    @table_presenter = Tabulator::GenreAssignmentsPresenter.new(@relatable.genre_assignments.includes(:genre).order(genre: {name: :asc}))
  end

  def create
    @genre_assignment = @relatable.genre_assignments.new(genre_assignment_params)
    if @genre_assignment.save
      redirect_to nested_path_for(relatable: @relatable)
    else
      redirect_to nested_path_for(relatable: @relatable), alert: "Could not add genre. You must choose a genre from the dropdown and can't assign the same genre twice."
    end
  end

  def destroy
    @genre_assignment.destroy
    head :no_content
  end

  private

  def genre_assignment_params
    params.expect(genre_assignment: [:genre_id])
  end

  def set_genre_assignment
    @genre_assignment = @relatable.genre_assignments.find(params.expect(:id))
  end
end
