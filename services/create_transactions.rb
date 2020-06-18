require './lib/requests_handler.rb'
require 'dry/monads'
require 'dry/monads/result'

class CreateTransactions
  include Dry::Monads[:result]
  include RequestsHandler

  def call(input)
    build_reference(input).bind { |input|
      send_request(input).bind { |input|
        create_source(input).bind { |input|
          build_response(input)
        }
      }
    }
  end

  private

  def build_reference(input)
    reference = input[:rider].phone.hex.to_s

    Success input.merge(pay_reference: reference)
  end

  def send_request(input)
    response = build_request(input)

    if response.status == 201
      Success input
    else
      Failure(message: parse_response(response.body), location: self.class)
    end
  end

  def build_request(input)
    basic_connection.post('transactions') do |req|
      req.body = build_payload(input)
      req.headers['Authorization'] = "Bearer #{ENV['WAMPI_PRV_KEY']}"
    end
  end

  def build_payload(input)
    trip, rider = input.values_at(:trip, :rider)
    payment_method = rider.payment_method
    cents = (trip.price * 100).to_i

    {
      acceptance_token: input[:acceptance_token],
      amount_in_cents: cents,
      currency: input[:currency],
      customer_email: rider.email,
      reference: input[:pay_reference],
      payment_source_id: payment_method.source_id,
      payment_method: {
        type: payment_method.method_type,
        installments: 24, # Default for automatic debit
        token: payment_method.token
      }
    }.to_json
  end

  def create_source(input)
    data = input.slice(:pay_reference, :trip).merge(payment_method: input[:rider].payment_method)
    source = Transaction.new(data)

    if source.save
      Success input.merge(message: "Transaction created successfully")
    else
      Failure(message: source.errors.messages, location: self.class)
    end
  end

  def build_response(input)
    Success input.slice(:message)
  end
end
