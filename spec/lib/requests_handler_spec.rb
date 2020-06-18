require 'spec_helper'

RSpec.describe RequestsHandler do
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
end
