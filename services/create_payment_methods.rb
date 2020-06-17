require 'dry/monads'
require 'dry/monads/result'

Dir["#{settings.current_dir}/services/validators/*.rb"].each { |file| require file }

class CreatePaymentMethods
  include Dry::Monads[:result]

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
    token = "Bearer #{ENV['WAMPI_PRV_KEY']}"

    conn = Faraday.new(url: ENV['WAMPI_URL']) do |f|
      f.adapter :net_http
    end

    response = conn.post('payment_sources') do |req|
      req.body = build_payload(input)
      req.headers['Authorization'] = token
    end

    if response.status == 200
      Success input
    else
      Failure(message: JSON.parse(response.body), location: self.class)
    end
  end

  def build_payload(input)
    { customer_email: input[:email], type: input[:method_type] }
      .merge(input.slice(:token, :acceptance_token)).to_json
  end

  def create_source(input)
    source = PaymentMethod.new(input.slice(:method_type, :token, :rider))

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
