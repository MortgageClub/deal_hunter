class HuntUndervalueHomesService
  def self.call
    homes = GetHomeListingsService.call
    homes.each do |home|
      next unless lower_price?(home) && was_not_hunted?(home)

      home.merge!({zestimate: @zestimate})
      SaveDataService.new(home).delay.call
      # SendSmsService.delay.call(home[:agent][:phone], home[:agent][:first_name], home[:address])
      # OfferMailer.notify_agent(home[:agent][:first_name], home[:agent][:email], home[:address]).deliver_later
      SendSmsService.delay.call('16507877799', home[:agent][:first_name], home[:address])
      OfferMailer.notify_agent(home[:agent][:first_name], 'billytran1222@gmail.com', home[:address], home[:city]).deliver_later
    end
  end

  private

  def self.was_not_hunted?(home)
    Deal.where(address: home[:address], zipcode: home[:zipcode]).last.nil?
  end

  def self.lower_price?(home)
    (@zestimate = CompareHomeValueService.call(home)) != -1
  end
end