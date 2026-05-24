class JobsController < ApplicationController
  def index
    @jobs = if params[:query]
      Job.search(params[:query], "name,department")
    else
      Job.all.order(:department, :name)
    end
  end
end
