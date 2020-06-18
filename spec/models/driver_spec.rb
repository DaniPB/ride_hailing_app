require 'spec_helper'

RSpec.describe Driver, type: :model do
  before :each do
    Driver.destroy_all
  end

  describe "associations" do
    it { should have_many(:trips).class_name('Trip') }
  end

  it "is valid with valid attributes" do
    driver = build(:driver)

    expect(driver).to be_valid
  end

  it "is not valid with wrong status type" do
    trip = build(:driver, status: 'aja')

    expect(trip).to_not be_valid
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
