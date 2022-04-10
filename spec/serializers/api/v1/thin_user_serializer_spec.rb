require 'rails_helper'

RSpec.describe Api::V1::ThinUserSerializer, type: :serializer do
  let(:user) { FactoryBot.build(:user) }
  let(:serializer) { described_class.new(user) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:subject) { JSON.parse(serialization.to_json) }

  describe 'Validating serializer' do
   it 'has an id that matches' do
      expect(subject['id']).to eql(user.id)
   end
   it 'has a Firstname that matches' do
      expect(subject['first_name']).to eql(user.first_name)
   end

   it 'has a Lastname that matches' do
      expect(subject['last_name']).to eql(user.last_name)
   end

   it 'has a Email that matches' do
      expect(subject['email']).to eql(user.email)
   end

   it 'has a Phone Number that matches' do
      expect(subject['phone']).to eql(user.phone)
   end

   it 'has a Date that matches' do
       expect(subject['date']).to eql(user.created_at)
    end
  end
end