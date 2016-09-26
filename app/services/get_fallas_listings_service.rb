class GetFallasListingsService
  attr_reader :market

  def initialize
    @market = Market.find_by_name("Dallas-Fort Worth")
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
      mls = row.search("td.d5m10").text
      price = row.search("td.d5m21").text.gsub!(",", "").gsub!("$", "").to_f
      address = row.search("td.d5m12").text
      city = row.search("td.d5m13").text
      deep_comps = ZillowService::GetDeepComps.call(address, "#{city}, TX")

      if deep_comps.present?
        listing = Listing.find_or_initialize_by(mls: mls)
        listing.mls = mls
        listing.address = address
        listing.city = city
        listing.added_date = format_time(row.search("td.d5m6").text)
        listing.sq_ft = row.search("td.d5m15").text.gsub!(",", "").to_f
        listing.year_built = row.search("td.d5m16").text.to_i
        listing.bed_rooms = row.search("td.d5m17").text.to_i
        listing.bath_rooms = row.search("td.d5m19").text.to_f
        listing.lot_sz = row.search("td.d5m20").text.to_f
        listing.price = price
        listing.market = market
        listing.hot_deal = is_hot_deal?(price, deep_comps[:avg_score].to_f, deep_comps[:zestimate].to_f)
        listing.comp = deep_comps[:avg_score].to_f
        listing.zestimate = deep_comps[:zestimate].to_f

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