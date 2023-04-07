rackup 'proxy.ru'

workers ENV.fetch("WEB_CONCURRENCY") { 3 }
threads 0, 12
preload_app!

# We can't use multiple puma workers - The pressure over the VM is too high and the process crashes
workers 2
worker_check_interval 1
worker_timeout 2
wait_for_less_busy_worker ENV.fetch('PUMA_WAIT_FOR_LESS_BUSY_WORKER', 0.001).to_f
