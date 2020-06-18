require 'spec_helper'

RSpec.describe CreatePaymentMethods do
  let(:rider)               { create(:rider) }
  let(:token)               { "tok_test_3873_65E5F468Da8E7C383cfEb07795861bD9" }
  let(:acceptance_token)    { "eyJhbGciOiJIUzI1NiJ9.eyJjb250cmFjdF9pZCI6MSwicGVybWFsaW5rIjoiaHR0cHM6Ly93b21waS5jby93cC1jb250ZW50L3VwbG9hZHMvMjAxOS8wOS9URVJNSU5PUy1ZLUNPTkRJQ0lPTkVTLURFLVVTTy1VU1VBUklPUy1XT01QSS5wZGYiLCJmaWxlX2hhc2giOiIzZGNkMGM5OGU3NGFhYjk3OTdjZmY3ODExNzMxZjc3YiIsImppdCI6IjE1OTI0MTAxOTMtODc2NjMiLCJleHAiOjE1OTI0MTM3OTN9.V8im0mknxsvXsp-s0JojRkgib14UjZba_l46Q4VYZWM" }
  let(:response)            { subject.(input) }

  let(:input)    { {
    email: rider.email,
    method_type: "CARD",
    token: token,
    acceptance_token: acceptance_token,
    accepted_token: true
  } }

  describe "#call" do
    before :each do
      PaymentMethod.destroy_all
      Rider.destroy_all
    end

    context "Valid input arguments" do
      context "Success Wompi API response" do
        it "should return a success response and create a PaymentMethod" do
          VCR.use_cassette("payment_sources_success_response") do
            expected_response = {
              message: "PaymentMethod created successfully"
            }

            expect(response).to be_success
            expect(response.success).to eq(expected_response)

            payment_method = PaymentMethod.last

            expect(payment_method.method_type).to eq("CARD")
            expect(payment_method.token).to eq(input[:token])
            expect(payment_method.rider).to eq(rider)
            expect(payment_method.source_id).to eq("1142")
          end
        end
      end

      context "Failure Wompi API response" do
        it "should return a failure response and not create a PaymentMethod" do
          VCR.use_cassette("payment_sources_failure_response") do
            input[:acceptance_token] = "invalid_token"

            expected_response = {
              message: {"error"=>{"messages"=>{"acceptance_token"=>["El token de aceptaci\u00F3n est\u00E1 en un formato incorrecto"]}, "type"=>"INPUT_VALIDATION_ERROR"}},
              location: CreatePaymentMethods
            }

            expect(response).to be_failure
            expect(response.failure).to eq(expected_response)

            expect(PaymentMethod.count).to eq(0)
          end
        end
      end

      context "There is not a rider with the input email" do
        it "should return a failure response and not create a PaymentMethod" do
          input[:email] = "invalid@email.com"

          expected_response = {
            message: "The rider invalid@email.com doesn't exist",
            location: CreatePaymentMethods
          }

          expect(response).to be_failure
          expect(response.failure).to eq(expected_response)

          payment_method = PaymentMethod.count

          expect(PaymentMethod.count).to eq(0)
        end
      end
    end

    context "Invalid input arguments" do
      it "Should return a failure response if the email is empty" do
        input[:email] = nil

        expected_response = {
          message: { :email=>["must be filled"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the email has invalid format" do
        input[:email] = 123

        expected_response = {
          message: { :email=>["must be a string"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the email has invalid format" do
        input[:email] = "invalid_email"

        expected_response = {
          message: { :email=>["not a valid email format"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the method_type is empty" do
        input[:method_type] = nil

        expected_response = {
          message: { :method_type=>["must be filled"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the method_type is invalid" do
        input[:method_type] = "AJA"

        expected_response = {
          message: { :method_type=>["must be CARD"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the method_type is invalid" do
        input[:method_type] = 123

        expected_response = {
          message: { :method_type=>["must be a string"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the token is empty" do
        input[:token] = nil

        expected_response = {
          message: { :token=>["must be filled"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the token is invalid" do
        input[:token] = 123

        expected_response = {
          message: { :token=>["must be a string"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the acceptance_token is empty" do
        input[:acceptance_token] = nil

        expected_response = {
          message: { :acceptance_token=>["must be filled"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the acceptance_token is invalid" do
        input[:acceptance_token] = 123

        expected_response = {
          message: { :acceptance_token=>["must be a string"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the accepted_token is empty" do
        input[:accepted_token] = nil

        expected_response = {
          message: { :accepted_token=>["must be filled"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end

      it "Should return a failure response if the acceptance_token is invalid" do
        input[:accepted_token] = 123

        expected_response = {
          message: { :accepted_token=>["must be boolean"] },
          location: CreatePaymentMethods
        }

        expect(response).to be_failure
        expect(response.failure).to eq(expected_response)
      end
    end
  end

  describe "#parse_response" do
    context "A json is received" do
      it "Should return a parsed response" do
        input = "{\"hola\":\"mundo\",\"hello\":\"world\"}"
        expected_response = { "hola" => "mundo", "hello" => "world" }

        response = subject.parse_response(input)

        expect(response).to eq(expected_response)
      end

      it "Should return a parsed response" do
        input = "{}"

        response = subject.parse_response(input)

        expect(response).to eq({})
      end
    end
  end

  describe "#basic_connection" do
    it "Should return a faraday connection" do
      response = subject.basic_connection

      expect(response.adapter).to eq(Faraday::Adapter::NetHttp)
      expect(response.url_prefix.host).to eq("sandbox.wompi.co")
    end
  end
end
