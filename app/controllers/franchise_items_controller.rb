class FranchiseItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_franchise
  before_action :set_franchise_item, only: [:destroy]
  before_action :validate_record_type, only: [:create]

  def editor
    @table_presenter = Tabulator::FranchiseItemsPresenter.new(@franchise.ordered_franchise_items.includes(:record))
  end

  def create
    @franchise_item = @franchise.franchise_items.new(franchise_item_params)
    if @franchise_item.save
      redirect_to editor_franchise_franchise_items_path(@franchise)
    else
      redirect_to editor_franchise_franchise_items_path(@franchise), alert: "This show/movie already belongs to a different franchise."
    end
  end

  def destroy
    @franchise_item.destroy
    head :no_content
  end

  private

  def franchise_item_params
    params.expect(franchise_item: [:record_type, :record_id])
  end

  def set_franchise_item
    @franchise_item = @franchise.franchise_items.find(params.expect(:id))
  end

  def set_franchise
    @franchise = Franchise.from_slug(params.expect(:franchise_id))
  end

  def validate_record_type
    record_type = franchise_item_params[:record_type]
    unless ["Movie", "Show"].include?(record_type)
      redirect_to editor_franchise_franchise_items_path(@franchise), alert: "Record type is invalid."
    end
  end
end
