class HuntUndervalueHomesService
  def self.call
    homes = GetHomeListingsService.call
    count = 0
    homes.each do |home|
      SaveDataService.new(home).call if was_not_hunted?(home)
      next unless lower_price?(home)
      count += 1


      SendSmsToAgentService.delay.call(home[:agent][:phone], home[:agent][:first_name], home[:address])
      OfferMailer.notify_agent(home[:agent][:first_name], home[:agent][:email], home[:address], home[:city]).deliver_later
    end
    GenerateReportService.call(count, homes.size, homes)
  end

  private

  def self.was_not_hunted?(home)
    Deal.where(address: home[:address], zipcode: home[:zipcode], price: home[:price]).last.nil?
  end

  def self.lower_price?(home)
    (home[:zestimate] = CompareHomeValueService.call(home)) != -1
  end
end