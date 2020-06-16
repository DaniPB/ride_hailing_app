# app.rb

require 'sinatra'

set :bind, '0.0.0.0'
set :port, 8080

set :database_file, 'config/database.yml'

class App < Sinatra::Base
  get "/" do
    "Hello world!"
  end
end
