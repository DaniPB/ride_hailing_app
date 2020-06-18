require 'spec_helper'
require './services/request_rides.rb'

RSpec.describe RequestRides do
  let(:rider)    { create(:rider) }
  let!(:driver)  { create(:driver) }
  let(:response) { subject.(input) }

  let(:input)    { {
    email: rider.email,
    from: { latitude: 4.6973867, longitude: -74.0493784 },
    to: { latitude: 4.654368, longitude: -74.0584483 }
  } }

  describe "#call" do
    before :each do
      Trip.destroy_all
      Rider.destroy_all
      Driver.destroy_all
    end

    context "Valid input arguments" do
      context "Success Wompi API response" do
        it "should return a success response and create a Trip" do
          driver2 = create(:driver, status: 'available')

          expected_response = {
            message: "Trip created successfully"
          }

          expect(response).to be_success
          expect(response.success).to eq(expected_response)

          trip = Trip.last

          expect(trip.rider).to eq(rider)
          expect(trip.driver).to eq(driver2)
          expect(trip.from).to eq({"latitude"=>"4.6973867", "longitude"=>"-74.0493784"})
          expect(trip.to).to eq({"latitude"=>"4.654368", "longitude"=>"-74.0584483"})
          expect(trip.starts_at.to_date).to eq(Date.today)
          expect(trip.ends_at.to_date).to eq(Date.today)
        end
      end

      context "There is not a rider with the input email" do
        it "should return a failure response and not create a Trip" do
          input[:email] = "invalid@email.com"

          expected_response = {
            message: "The rider invalid@email.com doesn't exist",
            location: GetRider
          }

          expect(response).to be_failure
          expect(response.failure).to eq(expected_response)

          trip = Trip.count

          expect(Trip.count).to eq(0)
        end
      end

      context "There is not available drivers" do
        it "should return a failure response and not create a Trip" do
          expected_response = {
            message: "There are not available drivers",
            location: RequestRides
          }

          expect(response).to be_failure
          expect(response.failure).to eq(expected_response)

          trip = Trip.count

          expect(Trip.count).to eq(0)
        end
      end
    end

    context "Invalid input arguments" do
      it "Should return a failure response if the email is empty" do
        input[:email] = nil

        expected_response = {
          message: { :email=>["must be filled"] },
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the email has invalid format" do
        input[:email] = 123

        expected_response = {
          message: { :email=>["must be a string"] },
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the email has invalid format" do
        input[:email] = "invalid_email"

        expected_response = {
          message: { :email=>["not a valid email format"] },
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if from is empty" do
        input[:from] = nil

        expected_response = {
          message: { :from=>["must be filled"] },
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if from is invalid" do
        input[:from] = "AJA"

        expected_response = {
          message: { :from=>["must be a hash"] },
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if to is invalid" do
        input[:to] = 123

        expected_response = {
          message: { :to=>["must be a hash"] },
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if to is empty" do
        input[:to] = nil

        expected_response = {
          message: { :to=>["must be filled"] },
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if latitude is invalid" do
        input[:from][:latitude] = 123

        expected_response = {
          message: {:from=>{:latitude=>["must be a float"]}},
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if longitude is invalid" do
        input[:from][:longitude] = 123

        expected_response = {
          message: {:from=>{:longitude=>["must be a float"]}},
          location: RequestRides
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end
    end
  end
end
