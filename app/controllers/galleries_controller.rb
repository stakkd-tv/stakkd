class GalleriesController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_gallery

  def posters
    @posters = @relatable.posters
  end

  def backgrounds
    @backgrounds = @relatable.backgrounds
  end

  def logos
    @logos = @relatable.logos
  end

  def videos
    @videos = @relatable.videos
  end

  def images
    @images = @relatable.images
  end

  private

  def require_gallery
    head :not_found unless @relatable.available_galleries.include?(action_name.to_sym)
  end
end
