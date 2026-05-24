class JobsController < ApplicationController
  def index
    @jobs = if params[:query]
      Job.search(params[:query], "name,department", {
        per_page: 100
      })
    else
      Job.all.order(:department, :name)
    end
  end
end
