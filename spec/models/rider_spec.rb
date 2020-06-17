require 'spec_helper'

RSpec.describe Rider, type: :model do

  describe "associations" do
    it { should belong_to(:payment_method).class_name('PaymentMethod') }
    it { should have_many(:trips).class_name('Trip') }
  end

  it "is valid with valid attributes" do
    rider = build(:rider)

    expect(rider).to be_valid
  end

  it "is not valid without some fields" do
    expect(subject).to_not be_valid

    expected_errors = {
      :email=>["can't be blank"],
      :phone=>["can't be blank"],
      :first_name=>["can't be blank"],
      :last_name=>["can't be blank"]
    }

    expect(subject.errors.messages).to eq(expected_errors)
  end
end
