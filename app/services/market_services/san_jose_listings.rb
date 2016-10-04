module MarketServices
  class SanJoseListings
    attr_reader :market

    def initialize(market = nil)
      @market = market || Market.find_by_name("San Jose")
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
        mls = row.search("td.d1085m10").text
        price = row.search("td.d1085m15").text.gsub(",", "").gsub("$", "").to_f
        address = row.search("td.d1085m13").text
        city = row.search("td.d1085m22").text
        deep_comps = ZillowService::GetDeepComps.call(address, "#{city}, CA")
        hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)

        if deep_comps.present?
          listing = Listing.find_or_initialize_by(mls: mls)

          listing.mls = mls
          listing.address = address
          listing.city = city
          listing.added_date = format_time(row.search("td.d1085m8").text)
          listing.chg_type = row.search("td.d1085m25").text
          listing.sq_ft = row.search("td.d1085m20").text.gsub(",", "").to_f
          listing.year_built = Time.now.year - row.search("td.d1085m23").text.to_i
          listing.bed_rooms = row.search("td.d1085m18").text.to_i
          listing.bath_rooms = row.search("td.d1085m19").text.to_f
          listing.lot_sz = row.search("td.d1085m21").text.gsub(",", "").to_f
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
            OfferMailer.notify_customer(listing).deliver_later
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
