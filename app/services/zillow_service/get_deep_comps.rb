module ZillowService
  class GetDeepComps
    include HTTParty
    NUMBER_OF_RESULTS = 6

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

      comparables.each do |comp|
        sum += comp['lastSoldPrice']['__content__'].to_f
        max = comp['lastSoldPrice']['__content__'].to_f if comp['lastSoldPrice']['__content__'].to_f > max
      end
      sum -= max
      sum / (NUMBER_OF_RESULTS - 1)
    end

    def self.ok?(response)
      response['comps']['message'].present? && response['comps']['message']['code'] == '0'
    end
  end
end