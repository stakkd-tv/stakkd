class VideosController < ApplicationController
  include Polymorphism::NestedRoutes
  include Polymorphism::Relatable

  before_action :require_authentication
  before_action :set_video, only: [:destroy]

  def index
    @table_presenter = Tabulator::VideosPresenter.new(@relatable.videos)
  end

  def create
    @video = @relatable.videos.new(video_params)
    if @video.save
      redirect_to nested_path_for(relatable: @relatable)
    else
      redirect_to nested_path_for(relatable: @relatable), alert: "Could not add that video. Please check that the video details are correct."
    end
  end

  def destroy
    @video.destroy
    head :no_content
  end

  private

  def set_video
    @video = @relatable.videos.find(params.expect(:id))
  end

  def video_params
    params.expect(video: [:source, :source_key, :type])
  end
end
