namespace :crawler do
  desc "Test crawler"
  task :test => :environment do
    GetHomeListingsService.call
  end

  desc "Test Zillow api"
  task :zillow => :environment do
    CompareHomeValueService.call
  end

  desc "Test send email to agent"
  task :email => :environment do
    OfferMailer.notify_agent("Asia C Allen", "thanhcuong1990@gmail.com" , "681 Las Palmas Ave").deliver_later
  end

  desc "Test send sms to agent"
  task :sms => :environment do
    SendSmsService.call('84989651186', 'Asia C Allen', "681 Las Palmas Ave")
  end
end