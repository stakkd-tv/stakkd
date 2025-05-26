class LanguagesController < ApplicationController
  def index
    @languages = Language.all.order(:code)
  end
end
