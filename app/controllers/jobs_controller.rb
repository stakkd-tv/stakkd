class JobsController < ApplicationController
  def index
    @jobs = if params[:query]
      Job.search(params[:query], "name,department", {
        sort_by: "name:asc",
        per_page: 100
      })
    else
      Job.all.order(:department, :name)
    end
  end
end
