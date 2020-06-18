require 'spec_helper'
require './services/finish_trips.rb'
require './services/request_trips.rb'

RSpec.describe FinishTrips do
  describe "#call" do
    let(:payment_method)   { create(:payment_method, source_id: "1142") }
    let(:rider)            { create(:rider, payment_method: payment_method) }
    let(:driver)           { create(:driver) }
    let(:trip)             { Trip.last }
    let(:acceptance_token) { "eyJhbGciOiJIUzI1NiJ9.eyJjb250cmFjdF9pZCI6MSwicGVybWFsaW5rIjoiaHR0cHM6Ly93b21waS5jby93cC1jb250ZW50L3VwbG9hZHMvMjAxOS8wOS9URVJNSU5PUy1ZLUNPTkRJQ0lPTkVTLURFLVVTTy1VU1VBUklPUy1XT01QSS5wZGYiLCJmaWxlX2hhc2giOiIzZGNkMGM5OGU3NGFhYjk3OTdjZmY3ODExNzMxZjc3YiIsImppdCI6IjE1OTI0NTg2MjMtNjU2MjEiLCJleHAiOjE1OTI0NjIyMjN9.3fSx1EWJeC0NgcN72ypCUwSFkAJfnevmenxKydfJ4SQ" }
    let(:from)             { { latitude: 4.6973867, longitude: -74.0493784 } }
    let(:to)               { { latitude: 4.654368, longitude: -74.0584483 } }
    let(:response)         { subject.(input) }

    let(:input)    { {
      id: 0000,
      current_location: { latitude: 4.6550203, longitude: -74.0558188 },
      acceptance_token: acceptance_token,
      currency: 'COP'
    } }

    before :each do
      Trip.destroy_all
      Rider.destroy_all
      Driver.destroy_all
      Transaction.destroy_all
      PaymentMethod.destroy_all
    end

    context "Valid input arguments" do
      context "Success Wompi API response" do
        it "should return a success response and create a Trip" do
          VCR.use_cassette("create_transaction_success_response") do
            driver.update(status: 'available')

            RequestTrips.new.(email: rider.email, from: from, to: to)

            trip = Trip.last
            input[:id] = trip.id

            expected_response = {
              message: "Trip finished successfully",
              total_charged: 8387.93
            }

            expect(response).to be_success
            expect(response.success).to eq(expected_response)

            trip = Trip.last
            transaction = Transaction.last


            expect(trip.rider).to eq(rider)
            expect(trip.driver).to eq(driver)
            expect(trip.status).to eq('finished')
            expect(trip.price).to eq(8387.93)
            expect(trip.starts_at.to_date).to eq(Date.today)
            expect(trip.ends_at.to_date).to eq(Date.today)
            expect(transaction.payment_method).to eq(payment_method)
            expect(transaction.trip).to eq(trip)
            expect(transaction.pay_reference).to eq(rider.phone.hex.to_s)
          end
        end
      end

      context "There is not a trip with the input id" do
        it "should return a failure response" do
          create(:trip)

          expected_response = {
            message: "Trip not found",
            location: FinishTrips
          }

          expect(response).to be_failure
          expect(response.failure).to eq(expected_response)
        end
      end

      context "There driver is not closer to the destination" do
        it "should return a failure response" do
          input[:current_location] = { latitude: 4.6864841, longitude: -74.0465669 }

          driver.update(status: 'available')

          RequestTrips.new.(email: rider.email, from: from, to: to)

          trip = Trip.last
          input[:id] = trip.id

          expected_response = {
            message: "You should be closer to the destination to finish this trip",
            location: FinishTrips
          }

          expect(response).to be_failure
          expect(response.failure).to eq(expected_response)
        end
      end
    end

    context "Invalid input arguments" do
      it "Should return a failure response if the id is empty" do
        input.delete(:id)

        expected_response = {
          message: { :id=>["is missing"] },
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the id has invalid format" do
        input[:id] = {}

        expected_response = {
          message: { :id=>["must be an integer"] },
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if acceptance_token is empty" do
        input[:acceptance_token] = nil

        expected_response = {
          message: { :acceptance_token=>["must be filled"] },
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if acceptance_token is invalid" do
        input[:acceptance_token] = 101

        expected_response = {
          message: { :acceptance_token=>["must be a string"] },
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if current_location is invalid" do
        input[:current_location] = 123

        expected_response = {
          message: { :current_location=>["must be a hash"] },
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if current_location is empty" do
        input[:current_location] = nil

        expected_response = {
          message: { :current_location=>["must be filled"] },
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if latitude is invalid" do
        input[:current_location][:latitude] = 123

        expected_response = {
          message: {:current_location=>{:latitude=>["must be a float"]}},
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if longitude is invalid" do
        input[:current_location][:longitude] = 123

        expected_response = {
          message: {:current_location=>{:longitude=>["must be a float"]}},
          location: FinishTrips
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end
    end
  end

  describe "#calculate_price" do
    it "Should return the price according with the distance, base fee and time" do
      from = { latitude: 4.6973867, longitude: -74.0493784 }
      to = { latitude: 4.654368, longitude: -74.0584483 }
      start_date = Time.now - 10.minutes
      end_date = Time.now

      trip = create(:trip, from: from, to: to, starts_at: start_date, ends_at: end_date)

      response = subject.calculate_price(trip: trip)

      expected_response = {
        trip: trip,
        total_charged: 10391.93
      }

      expect(response).to be_success
      expect(response.success).to eq(expected_response)
    end
  end

  describe "#distance_between" do
    let(:from) { [4.6973867, -74.0493784] }
    let(:to)   { [4.654368, -74.0584483] }

    it "Should return the distance between two points in km" do
      response = subject.distance_between(from, to, :km)

      expect(response).to eq(4.8879308722789325)
    end

    it "Should return the distance between two points in mi" do
      response = subject.distance_between(from, to, :mi)

      expect(response).to eq(3.0372194325215602)
    end
  end
end
