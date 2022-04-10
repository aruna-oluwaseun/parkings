require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingSessionSerializer, type: :serializer do
  let(:parking_session) { create(:parking_session) }
  let(:serializer) { described_class.new(parking_session) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  describe 'Validating serializer' do
   it 'has an id that matches' do

      expect(subject['id']).to eql(parking_session.id)
    end

   it 'has a File that matches' do

      expect(subject['uuid']).to  eql(parking_session.uuid)
   end

   it 'has a status that matches' do
      subject
      expect(subject['status']).to  eql(parking_session.status)
   end
  end
end
