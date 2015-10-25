namespace :db do
  desc "Destroy reports were created before three days ago"
  task :clear_report => :environment do
    Report.where("created_at < ?", 3.days.ago).destroy_all
  end
end