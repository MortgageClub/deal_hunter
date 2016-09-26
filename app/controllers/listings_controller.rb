class ListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:show]

  respond_to :html

  def index
    @market = Market.find(params[:market_id])

    @show_hotdeals_option = false
    if show_hotdeal_params.present?
      @show_hotdeals_option = show_hotdeal_params == "true"
      @listings = Listing.where(hot_deal: @show_hotdeals_option, market: @market).order('added_date DESC').paginate(:page => params[:page], :per_page => Setting.i(:default_per_page))
    else
      @listings = Listing.where(market: @market).order('added_date DESC').paginate(:page => params[:page], :per_page => Setting.i(:default_per_page))
    end

    respond_with(@listings)
  end

  def show
    respond_with(@listing)
  end

  def edit
  end

  def send_email
    listing = Listing.find(params[:listing_id])
    OfferMailer.notify_customer(listing).deliver_now

    flash[:notice] = "Sent email successfully."
    redirect_to market_listings_path(listing.market)
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def show_hotdeal_params
    params[:hot_deal_only]
  end
end
