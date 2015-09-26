env :PATH, ENV['PATH']

every 15.minutes do
  rake "crawler:hunt", :output => './log/hunt.log'
end
