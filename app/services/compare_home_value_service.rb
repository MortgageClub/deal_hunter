class CompareHomeValueService
  def self.call
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
    compare_home_value(data)
  end

  private

  def self.compare_home_value(data)
    price = data[:price].to_f
    zestimate = get_zestimate(data)
    result = (price <= (0.8 * zestimate)) ? zestimate : 0
    p "price: #{price}, zestimate: #{zestimate}"
    p "result: #{result}"
  end

  def self.get_zestimate(data)
    response = ZillowService::GetPropertyInfo.call(data[:address], data[:zipcode])
    zestimate = response["zestimate"]["amount"]["__content__"].to_f
    return 0 if zestimate < 1
    zestimate
  end

end