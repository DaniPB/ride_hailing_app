require 'spec_helper'

RSpec.describe Rider, type: :model do
  before :each do
    Rider.destroy_all
  end

  describe "associations" do
    it { should belong_to(:payment_method).class_name('PaymentMethod') }
    it { should have_many(:trips).class_name('Trip') }
  end

  it "is valid with valid attributes" do
    rider = build(:rider)

    expect(rider).to be_valid
  end

  it "is not valid with an existing email" do
    create(:rider, email: "rider@gmail.com")

    rider = build(:rider, email: "rider@gmail.com")

    expect(rider).to_not be_valid
  end

  it "is not valid with an existing phone" do
    create(:rider, phone: "3118924766")

    rider = build(:rider, phone: "3118924766")

    expect(rider).to_not be_valid
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
