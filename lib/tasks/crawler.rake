namespace :crawler do
  task :test => :environment do
    GetHomeListingsService.call
  end
end