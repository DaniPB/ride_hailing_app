require 'spec_helper'
require './services/create_transactions.rb'

RSpec.describe CreateTransactions do
  let(:payment_method)   { create(:payment_method, source_id: "1142") }
  let(:acceptance_token) { "eyJhbGciOiJIUzI1NiJ9.eyJjb250cmFjdF9pZCI6MSwicGVybWFsaW5rIjoiaHR0cHM6Ly93b21waS5jby93cC1jb250ZW50L3VwbG9hZHMvMjAxOS8wOS9URVJNSU5PUy1ZLUNPTkRJQ0lPTkVTLURFLVVTTy1VU1VBUklPUy1XT01QSS5wZGYiLCJmaWxlX2hhc2giOiIzZGNkMGM5OGU3NGFhYjk3OTdjZmY3ODExNzMxZjc3YiIsImppdCI6IjE1OTI0NTg2MjMtNjU2MjEiLCJleHAiOjE1OTI0NjIyMjN9.3fSx1EWJeC0NgcN72ypCUwSFkAJfnevmenxKydfJ4SQ" }
  let(:rider)            { create(:rider, phone: "3118924766", payment_method: payment_method) }
  let(:trip)             { create(:trip, price: 10000.0, rider: rider) }
  let(:response)         { subject.(input) }

  let(:input)    { {
    rider: rider,
    trip: trip,
    acceptance_token: acceptance_token,
    currency: "COP"
  } }

  describe "#call" do
    before :each do
      PaymentMethod.destroy_all
      Rider.destroy_all
      Trip.destroy_all
      Transaction.destroy_all
    end

    context "Valid input arguments" do
      context "Success Wompi API response" do
        it "should return a success response and create a Transaction" do
          VCR.use_cassette("post_transaction_success_response") do
            expected_response = {
              message: "Transaction created successfully"
            }

            expect(response).to be_success
            expect(response.success).to eq(expected_response)

            transaction = Transaction.last

            expect(transaction.payment_method).to eq(payment_method)
            expect(transaction.trip).to eq(trip)
            expect(transaction.pay_reference).to eq(rider.phone.hex.to_s)
          end
        end
      end

      context "Failure Wompi API response" do
        it "should return a failure response and not create a Transaction" do
          VCR.use_cassette("post_transaction_failure_response") do
            expected_response = {
              message: {"error"=>{"messages"=>{"reference"=>["La referencia ya ha sido usada"]}, "type"=>"INPUT_VALIDATION_ERROR"}},
              location: CreateTransactions
            }

            expect(response).to be_failure
            expect(response.failure).to eq(expected_response)

            expect(Transaction.count).to eq(0)
          end
        end
      end
    end
  end
end
