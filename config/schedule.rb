env :PATH, ENV['PATH']

every 15.minutes do
  rake "crawler:hunt", :output => './log/hunt.log'
end

every 1.day, at: '1:00 am' do
  rake "db:clear_report"
end
