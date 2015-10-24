PumaWorkerKiller.config do |config|
  config.ram           = 490
  config.percent_usage = 0.96
end
PumaWorkerKiller.enable_rolling_restart(12 * 3600)
