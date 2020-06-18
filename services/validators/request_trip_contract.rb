require './services/validators/application_contract.rb'
require 'dry-types'


module Types
  include Dry::Types()

  Coordinates = Types::Hash.schema(longitude: Types::Float, latitude: Types::Float)
end

class RequestTripContract < ApplicationContract
  params do
    required(:email).filled(:string)
    required(:from).filled(Types::Coordinates)
    required(:to).filled(Types::Coordinates)
  end

  rule(:email).validate(:email_format)
end
