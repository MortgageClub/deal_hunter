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
        return unless response.iframes.last.src

        response = agent.get response.iframes.last.src

        if response.code == "200"
          parse(response)
        end
      end
    end

    private

    def parse(response)
      rows_info = response.search("#divListingContainer table tr[style*='white-space: nowrap']")
      rows_address = response.search("#divListingContainer table tr[id*='trRow2']")

      rows_info.each_with_index do |row, index|
        mls = row.search("td:nth(2)").text.strip
        price = row.search("td:nth(4)").text.strip.gsub(",", "").gsub("$", "").to_f
        address = rows_address[index].search("table tr td:nth(3) tr:nth(1) td:nth(2) span:first").text.strip + " " + rows_address[index].search("table tr td:nth(3) tr:nth(1) td:nth(2) span:last").text.strip
        city = rows_address[index].search("table tr td:nth(3) tr:nth(2) td:nth(1) span").text.strip
        deep_comps = ZillowService::GetDeepComps.call(address, city)
        hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)

        if deep_comps.present?
          listing = Listing.find_or_initialize_by(mls: mls)

          listing.mls = mls
          listing.address = address
          listing.city = city
          listing.added_date = format_time(row.search("td:nth(12)").text.strip)
          listing.chg_type = row.search("td:nth(11)").text.strip
          listing.sq_ft = row.search("td:nth(7)").text.strip.gsub(",", "").to_f
          listing.bed_rooms = row.search("td:nth(5)").text.strip.to_i
          listing.bath_rooms = row.search("td:nth(6)").text.strip.to_f
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
