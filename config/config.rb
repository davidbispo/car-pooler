include ApplicationHelper

set :server, 'puma'
require 'json'
require "sinatra/config_file"

register Sinatra::ConfigFile

configure :development, :test do
  require "sinatra/reloader"
  require 'byebug'
  register Sinatra::Reloader
end