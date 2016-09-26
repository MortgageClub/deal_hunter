module ZillowService
  class GetDeepComps
    include HTTParty
    NUMBER_OF_RESULTS = 25

    def self.call(address, citystatezip)
      zpid = ZillowService::GetZpid.call(address, citystatezip)
      get_scores(zpid)
    end

    private

    def self.get_scores(zpid)
      params = {
        'zpid' => zpid,
        'count' => NUMBER_OF_RESULTS,
        'zws-id' => 'X1-ZWz1aylbpp3aiz_98wrk'
      }

      response = get('http://www.zillow.com/webservice/GetDeepComps.htm', query: params)

      return {} unless ok?(response)

      { zestimate: get_zestimate(response['comps']), avg_score: self.get_average_score(response['comps']) }
    end

    def self.get_zestimate(comps)
      comps['response'].try(:[], 'properties').try(:[], 'principal').try(:[], 'zestimate').try(:[], 'amount')['__content__'].to_f
    end

    def self.get_average_score(comps)
      comparables = comps['response'].try(:[], 'properties').try(:[], 'comparables').try(:[], 'comp')
      comparables = [comparables] if comparables.is_a? Hash
      sum, max = 0, 0
      count = 0

      comparables.each do |comp|
        if comp['lastSoldPrice'] || comp['zestimate']
          price = comp['lastSoldPrice'] ? comp['lastSoldPrice']['__content__'].to_f : comp['zestimate']['amount']['__content__'].to_f

          count += 1
          sum += price
          max = price if price > max
        end
      end

      if count == 1
        sum
      else
        sum -= max
        sum / (count - 1)
      end
    end

    def self.ok?(response)
      response['comps'].present? && response['comps']['message'].present? && response['comps']['message']['code'] == '0'
    end
  end
end