module MarketServices
  class CharlotteListings
    attr_reader :market

    def initialize(market = nil)
      @market = market || Market.find_by_name("Charlotte")
    end

    def call
      if market
        agent = Mechanize.new

        unless market.is_first_crawl
          uri = URI.parse market.portal_url

          cookie = Mechanize::Cookie.new domain: uri.host, name: "PageSize", value: "100", :path => uri.path, expires: (Date.today + 1).to_s
          agent.cookie_jar << cookie
        end

        response = agent.get market.portal_url

        if response.code == "200"
          parse(response)
        end
      end
    end

    private

    def parse(response)
      rows = response.search("div.singleLineDisplay")
      rows.each do |row|
        mls = row.search("td.d5m9").text
        price = row.search("td.d5m17").text.gsub(",", "").gsub("$", "").to_f
        address = row.search("td.d5m13").text
        city = row.search("td.d5m14").text
        city = "#{city}, NC"

        deep_comps = ZillowService::GetDeepComps.call(address, city)
        hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)

        if deep_comps.present?
          listing = Listing.find_or_initialize_by(mls: mls)

          listing.mls = mls
          listing.address = address
          listing.city = city
          listing.added_date = format_time(row.search("td.d5m6").text)
          listing.chg_type = row.search("td.d5m7").text
          listing.sq_ft = nil
          listing.year_built = nil
          listing.bed_rooms = row.search("td.d5m15").text.to_i
          listing.bath_rooms = row.search("td.d5m16").text.to_f
          listing.lot_sz = nil
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

      market.update(is_first_crawl: true)
    end

    def is_hot_deal?(price, comp, zestimate)
      price + market.rehab_cost <= market.arv_percent * (market.comps_weight * comp + market.zestimate_weight * zestimate)
    end

    def format_time(str)
      str.sub(eval('%r_(?<!\d)(\d{1,2})/(\d{1,2})/(\d{4}|\d{2})(?!\d)_').freeze){|m| "#$3-#$1-#$2"}.to_datetime
    end
  end
end
