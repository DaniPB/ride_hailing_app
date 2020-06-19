# app.rb

require 'sinatra'
require 'rake'
require 'json'
require 'faraday'
require 'puma'
require 'dotenv/load'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'sinatra/base'
require 'sinatra/custom_logger'
require 'logger'

require './services/create_payment_methods.rb'
require './services/request_trips.rb'
require './services/finish_trips.rb'

configure { set :server, :puma }

class App < Sinatra::Base
  helpers Sinatra::CustomLogger

  set :bind, '0.0.0.0'
  set :port, 8080
  set :database_file, 'config/database.yml'
  set :current_dir, Dir.pwd

  Dir["#{settings.current_dir}/models/*.rb"].each { |file| require file }

  configure :development, :production do
    logger = Logger.new(File.open("#{root}/log/#{environment}.log", 'a'))
    logger.level = Logger::DEBUG if development?
    set :logger, logger
  end

  # TODO: Strong params
  # TODO: Code errors
  # TODO: Token auth

  get '/' do
    "Hello World"
  end

  post "/payment_method" do
    input = parse_params(params["body"])
    response = CreatePaymentMethods.new.(input)

    base_response(response)
  end

  post "/trip" do
    input = parse_params(params["body"])
    response = RequestTrips.new.(input)

    base_response(response)
  end

  put "/trip" do
    input = parse_params(params["body"])
    response = FinishTrips.new.(input)

    base_response(response)
  end

  def parse_params(params)
    JSON.parse(params).deep_symbolize_keys!
  end

  def base_response(response)
    if response.success?
      status 200
      response.success.to_json
    else
      status 400
      response.failure.to_json
    end
  end

  run! if app_file == $0
end
