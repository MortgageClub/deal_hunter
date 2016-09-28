module ZillowService
  class GetZpid
    include HTTParty

    def self.call(address, citystatezip)
      #"X1-ZWz1a4mphgfggb_7zykg"
      params = {
        'address' => address,
        'citystatezip' => citystatezip,
        'zws-id' => ManageZillowKey.get_zillow_key
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
