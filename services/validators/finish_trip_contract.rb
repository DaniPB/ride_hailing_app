require './services/validators/application_contract.rb'
require 'dry-types'


module Types
  include Dry::Types()

  Coordinates = Types::Hash.schema(longitude: Types::Float, latitude: Types::Float)
end

class FinishTripContract < ApplicationContract
  params do
    required(:id).value(:integer)
    required(:acceptance_token).filled(:string)
    required(:current_location).filled(Types::Coordinates)
    required(:currency).filled(:string)
  end
end
