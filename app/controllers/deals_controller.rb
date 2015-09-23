class DealsController < ApplicationController
  before_action :set_deal, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @deals = Deal.all
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
    respond_with(@deal)
  end

  def update
    @deal.update(deal_params)
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
end
