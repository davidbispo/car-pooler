PROJECT_ROOT = Dir.pwd
Dir[File.join(__dir__, 'app', '**', '*.rb')].each { |file| require_relative file }
run CarPooling::API.new