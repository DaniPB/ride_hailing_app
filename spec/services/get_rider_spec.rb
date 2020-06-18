require 'spec_helper'
require './services/get_rider.rb'

RSpec.describe GetRider do
  describe "#call" do
    let(:response) { subject.(input) }
    let(:rider)    { create(:rider) }
    let(:input)    { { email: rider.email } }

    before :each do
      Rider.destroy_all
    end

    context "There is a rider with the input email" do
      it "should return a Success response" do
        expected_response = {
          email: rider.email,
          rider: rider
        }

        expect(response).to be_success
        expect(response.success).to eq(expected_response)
      end
    end
    context "There is not a rider with the input email" do
      it "should return a Failure response" do
        input[:email] = "invalid@email.com"

        expected_response = {
          message: "The rider invalid@email.com doesn't exist",
          location: GetRider
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end
    end
  end
end
