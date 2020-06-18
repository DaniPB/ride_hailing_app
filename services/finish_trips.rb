require './services/validators/finish_trip_contract.rb'
require './services/create_transactions.rb'
require './lib/utils.rb'
require 'dry/monads'
require 'dry/monads/result'
require 'geocoder'
require 'time_difference'

class FinishTrips
  include Dry::Monads[:result]
  include Utils

  BASE_FEE = 3500
  PRICE_KM = 1000
  PRICE_MIN = 200

  def call(input)
    validate(input).bind { |input|
      get_trip(input).bind { |input|
        get_driver(input).bind { |input|
          get_rider(input).bind { |input|
            finish_trip(input).bind { |input|
              build_response(input)
            }
          }
        }
      }
    }
  end

  def calculate_price(input)
    ends_at = Time.now
    trip = input[:trip]
    from = trip.from.transform_values(&:to_f)
    to = trip.to.transform_values(&:to_f)

    distance = distance_between(from.values, to.values)
    minutes = TimeDifference.between(trip.starts_at, ends_at).in_minutes

    price = ((distance * PRICE_KM) + (minutes * PRICE_MIN) + BASE_FEE).round(2)

    update_trip(input[:trip], price, ends_at)

    Success input.merge(total_charged: price)
  end

  private

  def validate(input)
    result = FinishTripContract.new.call(input)

    if result.success?
      Success input.deep_symbolize_keys
    else
      Failure(message: result.errors.to_h, location: self.class)
    end
  end

  def get_rider(input)
    rider = input[:trip].rider

    Success input.merge(rider: rider)
  end

  def get_driver(input)
    driver = input[:trip].driver

    Success input.merge(driver: driver)
  end

  def get_trip(input)
    trip = Trip.find_by(id: input[:id])

    if trip.present?
      Success input.merge(trip: trip)
    else
      Failure(message: "Trip not found", location: self.class)
    end
  end

  def finish_trip(input)
    finishable?(input).bind { |input|
      calculate_price(input).bind { |input|
        do_transaction(input)
      }
    }
  end

  def finishable?(input)
    distance = distance_between(input[:trip].to.values, input[:current_location].values)

    if distance <= 0.35
      Success input.merge(distance: distance)
    else
      Failure(message: "You should be closer to the destination to finish this trip", location: self.class)
    end
  end

  def update_trip(trip, price, ends_at)
    trip.update(price: price, ends_at: ends_at, status: 'finished')
  end

  def do_transaction(input)
    response = CreateTransactions.new.(input)

    if response.success?
      Success input.merge(message: "Trip finished successfully")
    else
      Failure(message: source.errors.messages, location: self.class)
    end
  end

  def build_response(input)
    Success input.slice(:message, :total_charged)
  end
end
