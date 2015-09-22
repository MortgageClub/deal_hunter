namespace :crawler do
  task :test => :environment do
    GetHomeListingsService.call
  end

  task :zillow => :environment do
    CompareHomeValueService.call
  end
end