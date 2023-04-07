PROJECT_ROOT = Dir.pwd
Dir[File.join(__dir__, 'app', '**', '*.rb')].each { |file| require_relative file }

require 'elastic-apm'
require "rack-timeout"
require "stackprof"

# use StackProf::Middleware,
#     enabled: true,
#     mode: :cpu,
#     interval: 20,
#     save_every: 500

ElasticAPM.start(app: CarPooling::API)
run CarPooling::API.new
at_exit { ElasticAPM.stop }