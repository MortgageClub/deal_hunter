namespace :crawler do
  task :test => :environment do
    GetHomeListingsService.call
  end

  task :zillow => :environment do
    CompareHomeValueService.call
  end

  task :email => :environment do
    OfferMailer.notify_agent("Asia C Allen", "thanhcuong1990@gmail.com" , "681 Las Palmas Ave").deliver_later
  end
end