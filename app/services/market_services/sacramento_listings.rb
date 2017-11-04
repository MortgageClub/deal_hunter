module MarketServices
  class SacramentoListings
    attr_reader :market

    def initialize(market = nil)
      @market = market || Market.find_by_name("Sacramento")
    end

    def call
      if market
        agent = Mechanize.new

        response = agent.get market.portal_url
        return unless response.iframe.src

        response = agent.get response.iframe.src
        return unless response.iframe_with(id: "WebTab_Frame0")

        response = agent.get response.iframe_with(id: "WebTab_Frame0").src

        if response.code == "200"
          parse(response)
        end

        p "Done"
      else
        p "Market is not exist"
      end
    end

    private

    def parse(response)
      rows_info = response.search("#divListingContainer table tr.search-result-row")

      rows_info.reverse.each do |row|
        mls = row.search("span.listingNum").text[9..-1]
        price = row.search("h4.rapIDXSearchResultsPriceTop").text.strip.gsub(",", "").gsub("$", "").to_f
        address = row.search("h4.address div").first.text.strip
        city = row.search("h4.address div").last.text.strip
        deep_comps = ZillowService::GetDeepComps.call(address, city)
        hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)

        if deep_comps.present?
          listing = Listing.find_or_initialize_by(mls: mls)
          listing.mls = mls
          listing.address = address
          listing.city = city
          listing.added_date = format_time(row.search("span[id$=spnDateUpdated]").text.strip[14..-1])
          listing.chg_type = row.search(".listingSubtype div.display-label").text.strip
          listing.sq_ft = row.search(".listingSqFt div.display-label").text.strip.gsub(",", "").to_f
          listing.bed_rooms = row.search(".listingBeds div.display-label").text.strip.to_i
          listing.bath_rooms = row.search(".listingBaths div.display-label").text.strip
          listing.year_built = row.search(".listingYrBuilt div.display-label").text.strip
          listing.lot_sz = row.search(".listingLotz div.display-label").text.strip
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
      if str
        str.sub(eval('%r_(?<!\d)(\d{1,2})/(\d{1,2})/(\d{4}|\d{2})(?!\d)_').freeze){|m| "#$3-#$1-#$2"}.to_datetime
      else
        DateTime.now
      end
    end
  end
end
