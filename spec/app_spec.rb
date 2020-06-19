require "spec_helper"

describe App, type: :request do
  let(:app)                 { App.new }
  let(:rider)               { create(:rider) }
  let(:token)               { "tok_test_3873_65E5F468Da8E7C383cfEb07795861bD9" }
  let(:acceptance_token)    { "eyJhbGciOiJIUzI1NiJ9.eyJjb250cmFjdF9pZCI6MSwicGVybWFsaW5rIjoiaHR0cHM6Ly93b21waS5jby93cC1jb250ZW50L3VwbG9hZHMvMjAxOS8wOS9URVJNSU5PUy1ZLUNPTkRJQ0lPTkVTLURFLVVTTy1VU1VBUklPUy1XT01QSS5wZGYiLCJmaWxlX2hhc2giOiIzZGNkMGM5OGU3NGFhYjk3OTdjZmY3ODExNzMxZjc3YiIsImppdCI6IjE1OTI0MTAxOTMtODc2NjMiLCJleHAiOjE1OTI0MTM3OTN9.V8im0mknxsvXsp-s0JojRkgib14UjZba_l46Q4VYZWM" }

  before :each do
    PaymentMethod.destroy_all
    Rider.destroy_all
    Trip.destroy_all
    Driver.destroy_all
    Transaction.destroy_all
  end

  context "POST to /payment_method" do
    let(:params)    { {
      email: rider.email,
      method_type: "CARD",
      token: token,
      acceptance_token: acceptance_token,
      accepted_token: true
    } }

    context "given a valid input" do
      it "creates a payment method" do
        VCR.use_cassette("payment_sources_success_response") do
          response = post "/payment_method", body: params.to_json

          expected_response = {
            "message" => "PaymentMethod created successfully"
          }

          body = JSON.parse(response.body)

          expect(body).to eq(expected_response)
          payment_method = PaymentMethod.last

          expect(payment_method.method_type).to eq("CARD")
          expect(payment_method.token).to eq(params[:token])
          expect(payment_method.rider).to eq(rider)
          expect(payment_method.source_id).to eq("1142")
        end
      end
    end

    context "given a invalid input" do
      it "creates a payment method" do
        params[:email] = "invalid@email.com"

        response = post "/payment_method", body: params.to_json

        expected_response = "The rider invalid@email.com doesn't exist"

        body = JSON.parse(response.body)

        expect(body["message"]).to eq(expected_response)

        expect(PaymentMethod.count).to eq(0)
      end
    end
  end

  context "POST to /trip" do
    let!(:driver)   { create(:driver, status: 'available') }
    let(:params)    { {
      email: rider.email,
      from: { latitude: 4.6973867, longitude: -74.0493784 },
      to: { latitude: 4.654368, longitude: -74.0584483 }
    } }

    context "given a valid input" do
      it "creates a trip and assign a driver" do
        response = post "/trip", body: params.to_json

        expected_response = {
          "message" => "Trip created successfully"
        }

        body = JSON.parse(response.body)

        expect(body).to eq(expected_response)

        trip = Trip.last

        expect(trip.rider).to eq(rider)
        expect(trip.driver).to eq(driver)
        expect(trip.status).to eq('onway')
        expect(trip.from).to eq({"latitude"=>"4.6973867", "longitude"=>"-74.0493784"})
        expect(trip.to).to eq({"latitude"=>"4.654368", "longitude"=>"-74.0584483"})
        expect(trip.starts_at.to_date).to eq(Date.today)
        expect(trip.ends_at.to_date).to eq(Date.today)
      end
    end

    context "given a invalid input" do
      it "creates a payment method" do
        params[:email] = "invalid@email.com"

        response = post "/trip", body: params.to_json

        expected_response = "The rider invalid@email.com doesn't exist"

        body = JSON.parse(response.body)

        expect(body["message"]).to eq(expected_response)

        expect(Trip.count).to eq(0)
      end
    end
  end

  context "PUT to /trip" do
    let(:payment_method)   { create(:payment_method, source_id: "1142") }
    let(:rider)            { create(:rider, payment_method: payment_method) }
    let!(:driver)          { create(:driver, status: 'available') }
    let(:from)             { { latitude: 4.6973867, longitude: -74.0493784 } }
    let(:to)               { { latitude: 4.654368, longitude: -74.0584483 } }
    let(:acceptance_token) { "eyJhbGciOiJIUzI1NiJ9.eyJjb250cmFjdF9pZCI6MSwicGVybWFsaW5rIjoiaHR0cHM6Ly93b21waS5jby93cC1jb250ZW50L3VwbG9hZHMvMjAxOS8wOS9URVJNSU5PUy1ZLUNPTkRJQ0lPTkVTLURFLVVTTy1VU1VBUklPUy1XT01QSS5wZGYiLCJmaWxlX2hhc2giOiIzZGNkMGM5OGU3NGFhYjk3OTdjZmY3ODExNzMxZjc3YiIsImppdCI6IjE1OTI0NTg2MjMtNjU2MjEiLCJleHAiOjE1OTI0NjIyMjN9.3fSx1EWJeC0NgcN72ypCUwSFkAJfnevmenxKydfJ4SQ" }
    let(:params)    { {
      current_location: { latitude: 4.6550203, longitude: -74.0558188 },
      acceptance_token: acceptance_token,
      currency: 'COP'
    } }

    context "given a valid input" do
      it "creates a trip and assign a driver" do
        VCR.use_cassette("create_transaction_success_response") do
          start_date = Time.now - 10.minutes
          end_date = Time.now

          RequestTrips.new.(email: rider.email, from: from, to: to)

          trip = Trip.last

          params[:id] = trip.id

          response = put "/trip", body: params.to_json

          expected_response = {
            "message" => "Trip finished successfully",
            "total_charged" => 8387.93
          }

          body = JSON.parse(response.body)

          expect(body).to eq(expected_response)

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

    context "The driver is not closer to the destination" do
      it "creates a payment method" do
        params[:current_location] = { latitude: 4.6864841, longitude: -74.0465669 }

        RequestTrips.new.(email: rider.email, from: from, to: to)

        trip = Trip.last
        params[:id] = trip.id

        response = put "/trip", body: params.to_json

        expected_response = "You should be closer to the destination to finish this trip"

        body = JSON.parse(response.body)

        expect(body["message"]).to eq(expected_response)
      end
    end
  end
end
