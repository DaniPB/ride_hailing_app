# app.rb

require 'sinatra'
require 'rake'
require 'faraday'
require 'dotenv/load'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

set :bind, '0.0.0.0'
set :port, 8080

set :database_file, 'config/database.yml'
set :current_dir, Dir.pwd

Dir["#{settings.current_dir}/models/*.rb"].each { |file| require file }
Dir["#{settings.current_dir}/services/*.rb"].each { |file| require file }

class App < Sinatra::Base
  get "/" do
    "Hello world!"
  end
end
