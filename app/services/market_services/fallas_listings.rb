module MarketServices
  class FallasListings
    attr_reader :market

    def initialize(market = nil)
      @market = market || Market.find_by_name("Dallas-Fort Worth")
    end

    def call
      if market
        response = Mechanize.new.get market.portal_url

        if response.code == "200"
          parse(response)
        end
      end
    end

    private

    def parse(response)
      rows = response.search("#_ctl0_m_divAsyncPagedDisplays .multiLineDisplay")

      rows.each do |row|
        mls = row.search(".d-fontWeight--bold").first.text
        price = row.search(".d-fontSize--largest").first.text.gsub(",", "").gsub("$", "").to_f
        address = row.search(".d-fontSize--largest").last.text.strip
        city = row.search(".d-fontSize--small").first.text.strip

        deep_comps = ZillowService::GetDeepComps.call(address, city)
        hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)

        if deep_comps.present?
          listing = Listing.find_or_initialize_by(mls: mls)

          listing.mls = mls
          listing.address = address
          listing.city = city
          listing.added_date = Time.now
          listing.chg_type = ''
          listing.sq_ft = row.search(".d-fontWeight--bold")[3].text.gsub(",", "").to_f
          listing.year_built = row.search(".d-fontWeight--bold")[4].text.to_i
          listing.bed_rooms = row.search(".d-fontWeight--bold")[1].text
          listing.bath_rooms = row.search(".d-fontWeight--bold")[2].text
          listing.lot_sz = ''
          listing.price = price
          listing.market = market
          listing.hot_deal = hot_deal
          listing.comp = deep_comps[:avg_score].to_f
          listing.zestimate = deep_comps[:zestimate].to_f
          listing.arv = market.comps_weight * deep_comps[:avg_score].to_f + market.zestimate_weight * deep_comps[:zestimate].to_f
          listing.arv_percentage = (price + market.rehab_cost) / listing.arv
          listing.rent = deep_comps[:rent_zestimate].to_f

          if (listing.is_sent == nil || listing.is_sent == false) && hot_deal
            # listing.is_sent = true
            # OfferMailer.notify_customer(listing).deliver_now
          end

          listing.save
        end
      end
    end

    def is_hot_deal?(price, comp, zestimate)
      price + market.rehab_cost <= market.arv_percent * (market.comps_weight * comp + market.zestimate_weight * zestimate)
    end

    def format_time(str)
      str.sub(eval('%r_(?<!\d)(\d{1,2})/(\d{1,2})/(\d{4}|\d{2})(?!\d)_').freeze){|m| "#$3-#$1-#$2"}.to_datetime
    end
  end
end
