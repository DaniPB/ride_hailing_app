require 'spec_helper'

RSpec.describe PaymentMethod, type: :model do
  before :each do
    PaymentMethod.destroy_all
  end

  describe "associations" do
    it { should belong_to(:rider).class_name('Rider') }
    it { should have_many(:transactions).class_name('Transaction') }
  end

  it "is valid with valid attributes" do
    payment_method = build(:payment_method)

    expect(payment_method).to be_valid
  end

  it "is not valid without some fields" do
    expect(subject).to_not be_valid

    expected_errors = {
      :token=>["can't be blank"],
      :source_id=>["can't be blank"]
    }

    expect(subject.errors.messages).to eq(expected_errors)
  end
end
