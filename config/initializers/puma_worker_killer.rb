PumaWorkerKiller.config do |config|
  config.percent_usage = 0.94
  config.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds
end
PumaWorkerKiller.enable_rolling_restart
