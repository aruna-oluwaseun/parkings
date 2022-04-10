require 'rails_helper'

RSpec.describe Api::Dashboard::SubscriberSerializer, type: :serializer do
  describe 'User/Subscriber serializer' do
    let!(:user) { create(:user, :confirmed, :with_vehicles, status: :active) }

    context 'user/subscriber serializer' do
      before do
        @serializer = Api::Dashboard::SubscriberSerializer.new(user)
        @serialization = ActiveModelSerializers::Adapter.create(@serializer)
      end

      subject do
        JSON.parse(@serialization.to_json)
      end

      it 'have the same values' do
        %w(id first_name last_name email).each do |attribute|
          expect(subject[attribute]).to eq(user[attribute])
        end
      end

      it 'have the same vehicles_owned' do
        expect(subject['vehicles_owned']).to eq(user.vehicles.size)
      end
    end

    context 'detailed user/subscriber serializer' do
      before do
        @serializer = Api::Dashboard::DetailedSubscriberSerializer.new(user)
        @serialization = ActiveModelSerializers::Adapter.create(@serializer)
      end

      subject do
        JSON.parse(@serialization.to_json)
      end

      it 'have the same values' do
        %w(phone status is_dev).each do |attribute|
          expect(subject[attribute]).to eq(user[attribute])
        end
      end

      it 'have the same dates' do
        expect(subject['created_at']).to eq(user.created_at.to_i)
        expect(subject['updated_at']).to eq(user.updated_at.to_i)
        expect(subject['confirmed_at']).to eq(user.confirmed_at.to_i)
      end

      it 'have the same vehicles' do
        serialization = ActiveModel::Serializer::CollectionSerializer.new(user.vehicles, serializer: Api::Dashboard::ThinVehicleSerializer)
        user_vehicles = JSON.parse(serialization.to_json)
        expect(subject['vehicles_list']).to eq(user_vehicles)
      end
    end
  end
end
