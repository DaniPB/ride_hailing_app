require 'spec_helper'

RSpec.describe Trip, type: :model do
  before :each do
    Trip.destroy_all
  end

  describe "associations" do
    it { should belong_to(:rider).class_name('Rider') }
    it { should belong_to(:driver).class_name('Driver') }
  end

  it "is valid with valid attributes" do
    trip = build(:trip)

    expect(trip).to be_valid
  end

  it "is not valid without some fields" do
    expect(subject).to_not be_valid

    expected_errors = {
      :from=>["can't be blank"],
      :to=>["can't be blank"],
      :starts_at=>["can't be blank"],
      :ends_at=>["can't be blank"]
    }

    expect(subject.errors.messages).to eq(expected_errors)
  end
end
