PROJECT_ROOT = Dir.pwd
Dir[File.join(__dir__, 'app', '**', '*.rb')].each { |file| require_relative file }

ElasticAPM.start(app: CarPooling::API)
run CarPooling::Proxy.new
at_exit { ElasticAPM.stop }


