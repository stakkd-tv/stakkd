class KeywordsController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_keyword_tagging, only: [:destroy]

  def index
    @tags = ActsAsTaggableOn::Tag
      .joins(:taggings)
      .where("taggings.context = ?", "keywords")
      .distinct
      .order(taggings_count: :desc)
      .limit(200)
    @table_presenter = Tabulator::KeywordTaggingsPresenter.new(@relatable.keyword_taggings.includes(:tag).order(tag: {name: :asc}))
  end

  def create
    @relatable.keyword_list.add(params[:tag])
    @relatable.save
    redirect_to nested_path_for(relatable: @relatable)
  end

  def destroy
    @keyword_tagging.destroy
    head :no_content
  end

  private

  def set_keyword_tagging
    @keyword_tagging = @relatable.keyword_taggings.find(params.expect(:id))
  end
end
