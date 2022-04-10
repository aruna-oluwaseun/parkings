require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe 'associations' do
    it { should have_many(:parking_sessions).dependent('nullify') }
    it { should have_many(:rules).class_name('Parking::VehicleRule') }
    it { should belong_to(:user).optional }
    it { should belong_to(:manufacturer).optional }
  end

  before do
    Manufacturer.create(name: 'Toyota')
  end

  describe 'creating vehicle' do
    it 'has valid factory' do
      vehicle = create(:vehicle)
      expect(vehicle).to be_valid
      expect(vehicle.plate_number).to be_present
      expect(vehicle.color).to be_present
      expect(vehicle.model).to be_present
      expect(vehicle.vehicle_type).to be_present
      expect(vehicle.status).to be_present
      expect(vehicle.manufacturer_id).to be_present
      expect(vehicle.user).to be_present
    end
  end
end
