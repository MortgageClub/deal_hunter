env :PATH, ENV['PATH']

# every 25.minutes do
#   rake "crawler:hunt", output: "./log/hunt.log"
# end

# every 1.day, at: "1:12 am" do
#   rake "db:clear_report"
# end

every 2.hours do
  rake "crawler:get_fallas", output: "./log/fallas.log"
end

# every 5.minutes do
#   rake "crawler:agents", output: "./log/crawler_agents.log"
# end