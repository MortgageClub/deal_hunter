class HuntUndervalueHomesService
  def self.call
    homes = GetHomeListingsService.call
    count = 0
    homes.each do |home|
      next unless lower_price?(home) && was_not_hunted?(home)
      count += 1

      SaveDataService.new(home).call
      SendSmsToAgentService.delay.call(home[:agent][:phone], home[:agent][:first_name], home[:address])
      OfferMailer.notify_agent(home[:agent][:first_name], home[:agent][:email], home[:address], home[:city]).deliver_later
    end
    GenerateReportService.delay.call(count, homes.size, homes)
  end

  private

  def self.was_not_hunted?(home)
    Deal.where(address: home[:address], zipcode: home[:zipcode], price: home[:price]).last.nil?
  end

  def self.lower_price?(home)
    (home[:zestimate] = CompareHomeValueService.call(home)) != -1
  end
end