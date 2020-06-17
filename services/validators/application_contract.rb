require 'dry-validation'

class ApplicationContract < Dry::Validation::Contract
  register_macro(:email_format) do
    unless Rider::VALID_EMAIL.match?(value)
      key.failure('not a valid email format')
    end
  end
end
