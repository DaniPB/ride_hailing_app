require 'spec_helper'

RSpec.describe Transaction, type: :model do
  before :each do
    Transaction.destroy_all
  end

  describe "associations" do
    it { should belong_to(:payment_method).class_name('PaymentMethod') }
    it { should belong_to(:trip).class_name('Trip') }
  end

  it "is valid with valid attributes" do
    transaction = build(:transaction)

    expect(transaction).to be_valid
  end

  it "is not valid without pay_reference" do
    expect(subject).to_not be_valid

    expected_errors = {
      :pay_reference=>["can't be blank"]
    }

    expect(subject.errors.messages).to eq(expected_errors)
  end
end
