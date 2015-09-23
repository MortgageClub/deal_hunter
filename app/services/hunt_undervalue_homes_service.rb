class HuntUndervalueHomesService
  def self.call
    homes = GetHomeListingsService.call
    homes.each do |home|
      next if (zestimate = CompareHomeValueService.call(home)) == -1

      home.merge({zestimate: zestimate})
      SaveDataService.new(home).call
    end
  end
end