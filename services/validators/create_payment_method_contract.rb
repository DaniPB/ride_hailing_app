require './services/validators/application_contract.rb'

class CreatePaymentMethodContract < ApplicationContract
  params do
    required(:email).filled(:string)
    required(:method_type).filled(:string)
    required(:token).filled(:string)
    required(:acceptance_token).filled(:string)
    required(:accepted_token).filled(:bool)
  end

  rule(:email).validate(:email_format)

  rule(:method_type) do
    key.failure('must be CARD') if value != 'CARD'
  end

  rule(:token, :acceptance_token) do
    key.failure('must be different to acceptance_token') if values[:token] == values[:acceptance_token]
  end

  rule(:accepted_token) do
    key.failure('the user must accept the acceptance_token') if value == false
  end
end
