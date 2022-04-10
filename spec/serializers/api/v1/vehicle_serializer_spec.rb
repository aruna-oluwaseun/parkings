require 'rails_helper'

RSpec.describe Api::V1::VehicleSerializer, type: :serializer do
  let(:vehicle) { FactoryBot.build(:vehicle) }
  let(:serializer) { described_class.new(vehicle) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  describe 'Validating serializer' do
    it 'has an id that matches' do
      expect(subject['id']).to eql(vehicle.id)
    end
    it 'has a plate number that matches' do
      expect(subject['plate_number']).to eql(vehicle.plate_number)
    end

    it 'has a vehicle type that matches' do
      expect(subject['vehicle_type']).to eql(vehicle.vehicle_type)
    end

    it 'has a Color that matches' do
      expect(subject['color']).to eql(vehicle.color)
    end

    it 'has a Model that matches' do
      expect(subject['model']).to eql(vehicle.model)
    end

    it 'has a user_id that matches' do
      expect(subject['user_id']).to eql(vehicle.user_id)
    end
  end
end