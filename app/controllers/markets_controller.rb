class MarketsController < ApplicationController
  before_action :authorize_user!
  before_action :set_market, only: [:show, :edit, :update, :destroy, :get_listings]

  def index
    @markets = Market.paginate(:page => params[:page], :per_page => Setting.i(:default_per_page))
  end

  def new
    @market = Market.new
  end

  def create
    @market = Market.new(market_params)

    respond_to do |format|
      if @market.save
        format.html { redirect_to @market, notice: 'Market was successfully created.' }
        format.json { render :show, status: :created, location: @market }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def get_listing
    market = Market.find(params[:market_id])
    if market
      case market.name
      when "Dallas-Fort Worth"
        MarketServices::FallasListings.new(market).call
      when "Orlando"
        MarketServices::OrlandoListings.new(market).call
      when "San Jose"
        MarketServices::SanJoseListings.new(market).call
      when "Fort Lauderdale"
        MarketServices::FortLauderdaleListings.new(market).call
      when "Sacramento"
        MarketServices::SacramentoListings.new(market).call
      when "Tampa"
        MarketServices::TampaListings.new(market).call
      when "Houston"
        MarketServices::HoustonListings.new(market).call
      when "Charlotte"
        MarketServices::CharlotteListings.new(market).call
      when "Raleigh-Durham"
        MarketServices::RaleighListings.new(market).call
      when "Seattle"
        MarketServices::SeattleListings.new(market).call
      when "Miami"
        MarketServices::MiamiListings.new(market).call
      else
      end
    end

    respond_to do |format|
      format.html { redirect_to markets_path, notice: "#{market.name}\'s listings updated." }
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @market.update(market_params)
        format.html { redirect_to @market, notice: 'Market was successfully updated.' }
        format.json { render :show, status: :ok, location: @market }
      else
        format.html { render :edit }
        format.json { render json: @market.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @market.destroy

    respond_to do |format|
      format.html { redirect_to markets_url, notice: 'Market was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_market
    @market = Market.find(params[:id])
  end

  def authorize_user!
    authorize User
  end

  def market_params
    params.require(:market).permit(:name, :portal_url, :rehab_cost, :arv_percent, :comps_weight, :zestimate_weight, :from_email, :to_email)
  end
end
