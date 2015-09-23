module ZillowService
  class GetZpid
    include HTTParty
    include ZillowService::ZillowApi

    def self.call(address, citystatezip)
      params = {
        'address' => address,
        'citystatezip' => citystatezip,
        'zws-id' => ZILLOW_KEY
      }
      response = get('http://www.zillow.com/webservice/GetDeepSearchResults.htm', query: params)

      if response['searchresults'] && response['searchresults']['response']
        property_info = response['searchresults']['response']['results']['result']
        return property_info[0]['zpid'] if property_info[0]
        property_info['zpid']
      end
    end
  end
end
