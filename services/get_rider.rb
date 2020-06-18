require 'dry/monads'
require 'dry/monads/result'

class GetRider
  include Dry::Monads[:result]

  def call(input)
    rider = Rider.find_by(email: input[:email])

    if rider.present?
      Success input.merge(rider: rider)
    else
      Failure(message: "The rider #{input[:email]} doesn't exist", location: self.class)
    end
  end
end
