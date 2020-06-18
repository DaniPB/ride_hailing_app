require './services/validators/create_payment_method_contract.rb'
require './lib/requests_handler.rb'
require 'dry/monads'
require 'dry/monads/result'

class CreatePaymentMethods
  include Dry::Monads[:result]
  include RequestsHandler

  def call(input)
    validate(input).bind { |input|
      get_rider(input).bind { |input|
        send_request(input).bind { |input|
          create_source(input).bind { |input|
            build_response(input)
          }
        }
      }
    }
  end

  private

  def validate(input)
    result = CreatePaymentMethodContract.new.call(input)

    if result.success?
      Success input.deep_symbolize_keys
    else
      Failure(message: result.errors.to_h, location: self.class)
    end
  end

  def get_rider(input)
    rider = Rider.find_by(email: input[:email])

    if rider.present?
      Success input.merge(rider: rider)
    else
      Failure(message: "The rider #{input[:email]} doesn't exist", location: self.class)
    end
  end

  def send_request(input)
    response = build_request(input)

    if response.status == 200
      source_id = parse_response(response.body)["data"]["id"]

      Success input.merge(source_id: source_id)
    else
      Failure(message: parse_response(response.body), location: self.class)
    end
  end

  def build_request(input)
    conn = Faraday.new(url: ENV['WAMPI_URL']) do |f|
      f.adapter :net_http
    end

    conn.post('payment_sources') do |req|
      req.body = build_payload(input)
      req.headers['Authorization'] = "Bearer #{ENV['WAMPI_PRV_KEY']}"
    end
  end

  def build_payload(input)
    { customer_email: input[:email], type: input[:method_type] }
      .merge(input.slice(:token, :acceptance_token)).to_json
  end

  def create_source(input)
    source = PaymentMethod.new(input.slice(:method_type, :token, :rider, :source_id))

    if source.save
      Success input.merge(message: "PaymentMethod created successfully")
    else
      Failure(message: source.errors.messages, location: self.class)
    end
  end

  def build_response(input)
    Success input.slice(:message)
  end
end
