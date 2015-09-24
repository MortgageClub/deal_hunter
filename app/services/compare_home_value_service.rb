class CompareHomeValueService
  def self.call(home)
    compare_home_value(home)
  end

  private

  def self.compare_home_value(home)
    price = home[:price].to_f
    zestimate = ZillowService::GetZestimate.call(home[:address], home[:zipcode])
    (price <= (0.95 * zestimate)) ? zestimate : -1
  end
end