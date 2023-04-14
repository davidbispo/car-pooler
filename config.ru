PROJECT_ROOT = Dir.pwd
Dir[File.join(__dir__, 'app', '**', '*.rb')].each { |file| require_relative file }

require 'elastic-apm'
require "rack-timeout"
# use Rack::Timeout, service_timeout: 1.3

ElasticAPM.start(app: CarPooling::API)
run CarPooling::API.new
at_exit { ElasticAPM.stop }