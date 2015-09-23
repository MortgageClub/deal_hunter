module ZillowService
  class GetZestimate
    include HTTParty
    include ZillowService::ZillowApi

    def self.call(address, citystatezip)
      property_data = get_property_data(address, citystatezip)
      monthly_payments = get_monthly_payments_advanced(property_data)
      data = parse_payments(monthly_payments, property_data)
      get_zestimate(data)
    end

    private

    def self.get_property_data(address, citystatezip)
      params = {
        'address' => address,
        'citystatezip' => citystatezip,
        'zws-id' => ZILLOW_KEY
      }
      get('http://www.zillow.com/webservice/GetDeepSearchResults.htm', query: params)
    end

    def self.get_monthly_payments_advanced(property_data)
      return unless property_data['searchresults'] && property_data['searchresults']['response']

      @monthly_payments ||= begin
        property = property_data['searchresults']['response']['results']['result'][0] || property_data['searchresults']['response']['results']['result']
        property.merge!({
          useCode: USE_CODE[property['useCode']]
        })

        params = {
          'zip' => property['address']['zipcode'],
          'price' => property['zestimate']['amount']['__content__'],
          'zws-id' => ZILLOW_KEY
        }

        get('http://www.zillow.com/webservice/mortgage/CalculateMonthlyPaymentsAdvanced.htm', query: params)
      end
    end

    def self.parse_payments(monthly_payments, property_data)
      return if monthly_payments.nil?
      return if monthly_payments['paymentsdetails']['response'].nil?

      property = property_data['searchresults']['response']['results']['result'][0] || property_data['searchresults']['response']['results']['result']
      property.merge({
        :monthlyTax => monthly_payments['paymentsdetails']['response']['monthlypropertytaxes'],
        :monthlyInsurance => monthly_payments['paymentsdetails']['response']['monthlyhazardinsurance']
      })
    end

    def self.get_zestimate(data)
      zestimate = data.try(:[], 'zestimate').try(:[],'amount').try(:[], '__content__')
      zestimate.present? ? zestimate.to_f : 0
  end
  end
end