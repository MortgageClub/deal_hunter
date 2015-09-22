class CompareHomeValueService
  def self.call
    call_zillow
  end

  private

  def self.call_zillow
    data = {
        :price => 130000,
        :address => "681 Las Palmas Ave",
        :city => "Sacramento",
        :zipcode => "95815",
        :office_name => "Better Homes and Gardens RE Mason-McDuffie",
        :agent_name => "Asia C Allen ",
        :agent_phone => "916-628-6666",
        :agent_email => "asia.allen@bhghome.com"
    }
    response = ZillowService::GetPropertyInfo.call(data[:address], data[:zipcode])
    puts "Listing Price: #{data[:price]}"
    puts "Zestimate: #{response["zestimate"]["amount"]["__content__"]}"
  end

end