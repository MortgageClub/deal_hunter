class HuntUndervalueHomesService
  def self.call
    return true

    homes = GetHomeListingsService.call
    number_of_deal = 0
    homes.each do |home|
      next if was_saved?(home) || (scores = get_scores(home)).empty?

      home[:zestimate] = scores[:zestimate]
      home[:comp] = scores[:avg_score]

      if hot_deal?(home, scores[:avg_score])
        SendSmsToAgentService.call(home[:agent][:phone], home[:agent][:first_name], home[:address]) if home[:agent][:phone].present?
        OfferMailer.notify_agent(home[:agent][:first_name], home[:agent][:email], home[:address], home[:city]).deliver_now
        number_of_deal += 1
      end
      SaveDataService.new(home, hot_deal?(home, scores[:avg_score])).call
    end
    GenerateReportService.call(number_of_deal, homes.size, homes)
  end

  private

  def self.get_scores(home)
    ZillowService::GetDeepComps.call(home[:address], home[:zipcode])
  end

  def self.was_saved?(home)
    Deal.where(address: home[:address], zipcode: home[:zipcode], price: home[:price]).last.present?
  end

  def self.hot_deal?(home, compscore)
    home[:price] <= 0.85 * compscore
  end
end