class CountriesController < ApplicationController
  def index
    @countries = Country.all.order(:code)
  end
end
