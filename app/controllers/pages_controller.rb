class PagesController < ApplicationController
  def index
  end

  def about
    @contributors = Github::Contributors.all
  end

  def contribute
  end
end
