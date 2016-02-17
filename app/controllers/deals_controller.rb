class DealsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deal, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @show_hotdeals_option = false
    if show_hotdeal_params.present?
      @show_hotdeals_option = show_hotdeal_params == "true"
      @deals = Deal.where(hot_deal: @show_hotdeals_option).order('created_at DESC').includes(:agent).paginate(:page => params[:page], :per_page => Setting.i(:default_per_page))
    else
      @deals = Deal.order('created_at DESC').includes(:agent).paginate(:page => params[:page], :per_page => Setting.i(:default_per_page))
    end

    respond_with(@deals)
  end

  def show
    respond_with(@deal)
  end

  def new
    @deal = Deal.new
    @agents = Agent.all
    respond_with(@deal)
  end

  def edit
    @agents = Agent.all
  end

  def create
    @deal = Deal.new(deal_params)
    @deal.save
    @agents = Agent.all
    respond_with(@deal)
  end

  def update
    @deal.update(deal_params)
    @agents = Agent.all
    respond_with(@deal)
  end

  def destroy
    @deal.destroy
    respond_with(@deal)
  end

  private

  def set_deal
    @deal = Deal.find(params[:id])
  end

  def deal_params
    params.require(:deal).permit(:listing_id, :price, :address, :city, :zipcode, :agent_id)
  end

  def show_hotdeal_params
    params[:hot_deal_only]
  end
end
