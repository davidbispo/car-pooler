PROJECT_ROOT = Dir.pwd
Dir[File.join(__dir__, 'app', '**', '*.rb')].each { |file| require_relative file }

# require 'elastic-apm'
require "rack-timeout"
require "stackprof"
# use Rack::Timeout, service_timeout: 0.4
#
use StackProf::Middleware,
    enabled: true,
    mode: :cpu,
    interval: 2,
    save_every: 5,
    path:'./tmp'

# ElasticAPM.start(app: CarPooling::API)
run CarPooling::API.new
at_exit { ElasticAPM.stop }