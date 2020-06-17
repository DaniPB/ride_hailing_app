require 'spec_helper'

RSpec.describe Transaction, type: :model do

  describe "associations" do
    it { should belong_to(:payment_method).class_name('PaymentMethod') }
    it { should belong_to(:trip).class_name('Trip') }
  end

  it "is valid with valid attributes" do
    transaction = build(:transaction)

    expect(transaction).to be_valid
  end
end
