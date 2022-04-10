require 'rails_helper'

RSpec.describe Api::Dashboard::NotificationSerializer, type: :serializer do
  let!(:user) { create(:user, :confirmed) }
  let!(:vehicle) { create(:vehicle) }
  let!(:parking_session) { create(:parking_session, vehicle: vehicle) }
  let!(:user_notification) { create(:user_notification , user: user, parking_session: parking_session ) }
  let(:serializer) { described_class.new(user_notification) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  describe 'Validating serializer' do

    it 'has an title that matches' do
      expect(subject['id']).to eql(user_notification.id)
    end

    it 'has a Title that matches' do
      expect(subject['title']).to eql(user_notification.title)
    end

    it 'has a body that matches' do
      expect(subject['text']).to eql(user_notification.text)
    end

    it 'has a type that matches' do
      expect(subject['template']).to eql(user_notification.template)
    end

    it 'has a Licensced plate number that matches' do
     expect(subject['plate_number']).to eql(parking_session.vehicle.plate_number)
   end
  end
end