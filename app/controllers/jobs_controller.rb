class JobsController < ApplicationController
  def index
    @jobs = if params[:query]
      Job.search(params[:query]).order(:department, :name)
    else
      Job.all.order(:department, :name)
    end
  end
end
