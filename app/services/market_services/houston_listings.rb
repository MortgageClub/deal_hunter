module MarketServices
  class HoustonListings
    attr_reader :market

    def initialize(market = nil)
      @market = market || Market.find_by_name("Houston")
    end

    def call
      if market
        agent = Mechanize.new

        response = agent.get market.portal_url

        if response.code == "200"
          parse(response)
        end

        unless market.is_first_crawl
          [1, 2, 3, 4, 5].each do |index|
            response.form["ResP"] = index
            response.form["SwitchTab"] = 0
            response.form["ShowMySearchResult"] = 1

            response = response.form.submit

            if response.code == "200"
              parse(response)
            end
          end

          market.update(is_first_crawl: true)
        end
      end
    end

    private

    def parse(response)
      rows = response.search("table[id*=tblProp] .PropertyDetailGridTable")

      rows.each do |row|
        mls = row.search("tr")[0].search("td")[1].search("b").text
        price = row.search("tr")[1].search("td")[1].search("b").text.gsub(",", "").gsub("$", "").to_f
        address = row.search("tr")[0].search("td")[0].search("b").text
        city = row.search("tr")[2].search("td")[1].search("b").text

        deep_comps = ZillowService::GetDeepComps.call(address, city)
        hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)

        if deep_comps.present?
          listing = Listing.find_or_initialize_by(mls: mls)

          listing.mls = mls
          listing.address = address
          listing.city = city
          listing.added_date = Time.now
          listing.chg_type = nil
          listing.sq_ft = nil
          listing.year_built = nil
          listing.bed_rooms = nil
          listing.bath_rooms = nil
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
    end

    def is_hot_deal?(price, comp, zestimate)
      price + market.rehab_cost <= market.arv_percent * (market.comps_weight * comp + market.zestimate_weight * zestimate)
    end
  end
end
