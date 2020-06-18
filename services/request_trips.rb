require './services/validators/request_trip_contract.rb'
require 'dry/monads'
require 'dry/monads/result'

class RequestTrips
  include Dry::Monads[:result]

  def call(input)
    validate(input).bind { |input|
      get_rider(input).bind { |input|
        find_driver(input).bind { |input|
          create_source(input).bind { |input|
            build_response(input)
          }
        }
      }
    }
  end

  private

  def validate(input)
    result = RequestTripContract.new.call(input)

    if result.success?
      Success input.deep_symbolize_keys
    else
      Failure(message: result.errors.to_h, location: self.class)
    end
  end

  def get_rider(input)
    GetRider.new.(input)
  end

  def find_driver(input)
    driver = Driver.where(status: 'available').last

    if driver.present?
      Success input.merge(driver: driver)
    else
      Failure(message: "There are not available drivers", location: self.class)
    end
  end

  def create_source(input)
    default_time = Time.now
    data = input.slice(:from, :to, :driver, :rider).merge(starts_at: default_time, ends_at: default_time, status: 'onway')
    source = Trip.new(data)

    if source.save
      Success input.merge(message: "Trip created successfully")
    else
      Failure(message: source.errors.messages, location: self.class)
    end
  end

  def build_response(input)
    Success input.slice(:message)
  end
end
