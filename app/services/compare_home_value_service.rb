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
    zestimate = ZillowService::GetZestimate.call(data[:address], data[:zipcode])
    p "price: #{price}, zestimate: #{zestimate}"
    (price <= (0.8 * zestimate)) ? zestimate : -1
  end
end