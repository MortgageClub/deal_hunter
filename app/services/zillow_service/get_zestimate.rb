module ZillowService
  class GetZestimate
    include HTTParty

    def self.call(address, citystatezip)
      property_data = get_property_data(address, citystatezip)
      get_zestimate(property_data)
    end

    private

    def self.get_property_data(address, citystatezip)
      params = {
        'address' => address,
        'citystatezip' => citystatezip,
        'zws-id' => ManageZillowKey.get_zillow_key
      }

      response = get('http://www.zillow.com/webservice/GetDeepSearchResults.htm', query: params)
      response.try(:[], 'searchresults').try(:[], 'response').try(:[], 'results').try(:[], 'result')
    end

    def self.get_zestimate(data)
      zestimate = data.try(:[], 'zestimate').try(:[], 'amount').try(:[], '__content__')
      zestimate.present? ? zestimate.to_f : 0
    end
  end
end