module MarketServices
  class OrlandoListings
    attr_reader :market

    def initialize
      @market = Market.find_by_name("Orlando")
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
      rows = response.search("div.singleLineDisplay")

      rows.each do |row|
        mls = row.search("td.d5m13").text
        price = row.search("td.d5m21").text.gsub(",", "").gsub("$", "").to_f
        address = row.search("td.d5m15").text.match(",").pre_match
        city = row.search("td.d5m15").text.match(",").post_match
        deep_comps = ZillowService::GetDeepComps.call(address, city)
        hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)

        if deep_comps.present?
          listing = Listing.find_or_initialize_by(mls: mls)

          listing.mls = mls
          listing.address = address
          listing.city = city
          listing.added_date = format_time(row.search("td.d5m9").text)
          listing.chg_type = row.search("td.d5m10").text
          listing.sq_ft = row.search("td.d5m20").text.gsub(",", "").to_f
          listing.bed_rooms = row.search("td.d5m16").text.to_i
          listing.bath_rooms = row.search("td.d5m18").text.to_f
          listing.price = price
          listing.market = market
          listing.hot_deal = hot_deal
          listing.comp = deep_comps[:avg_score].to_f
          listing.zestimate = deep_comps[:zestimate].to_f
          listing.arv = market.comps_weight * deep_comps[:avg_score].to_f + market.zestimate_weight * deep_comps[:zestimate].to_f
          listing.arv_percentage = (price + market.rehab_cost) / listing.arv
          listing.rent = deep_comps[:rent_zestimate].to_f

          if (listing.is_sent == nil || listing.is_sent == false) && hot_deal
            listing.is_sent = true
            OfferMailer.notify_customer(listing).deliver_now
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
