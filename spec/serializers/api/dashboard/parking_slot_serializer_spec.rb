require 'rails_helper'

RSpec.describe Api::Dashboard::Parking::SlotSerializer, type: :request do
  describe 'Validating serializer' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:parking_admin) { create(:admin, role: parking_admin_role) }
    let(:town_manager) { create(:admin, role: town_manager_role) }
    let(:parking_lot) { create(:parking_lot, admins: [parking_admin, town_manager]) }
    let(:parking_slot) { create(:parking_slot, parking_lot: parking_lot) }

    context 'with Slot Serializer' do
      before do
        @serializer = Api::Dashboard::Parking::SlotSerializer.new(parking_slot)
        @serialization = ActiveModelSerializers::Adapter.create(@serializer)
      end

      subject do
        JSON.parse(@serialization.to_json)
      end

      it 'have the same values' do
        %w(id name status archived coordinate_parking_plan).each do |attribute|
          expect(subject[attribute]).to eq(parking_slot[attribute])
        end
      end
    end

    context 'with Detailed Slot Serializer' do
      before do
        @serializer = Api::Dashboard::Parking::DetailedSlotSerializer.new(parking_slot, scope: admin)
        @serialization = ActiveModelSerializers::Adapter.create(@serializer)
      end

      subject do
        put "/api/dashboard/parking_slots/#{parking_slot.id}", headers: { Authorization: Authorizer.generate_token(admin) },
        params:
        {
          parking_slot: {
            name: 'ABC-123'
          }
        }
        JSON.parse(@serialization.to_json)
      end

      it 'have the same log values' do
        subject
        parking_slot.reload
        log_user = Admin.find_by(id: parking_slot.logs.first.whodunnit)
        %w(id username email name status).each do |attribute|
          expect(subject['updated_by'][attribute]).to eq(log_user[attribute])
        end
      end

      it 'have the same dates' do
        expect(subject['created_at']).to eq(parking_slot.created_at.to_i)
        expect(subject['updated_at']).to eq(parking_slot.updated_at.to_i)
      end
    end
  end
end
