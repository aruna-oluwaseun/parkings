require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingSlotsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:parking_admin) { create(:admin, role: parking_admin_role) }
  let(:parking_lot) { create(:parking_lot, admins: [parking_admin, town_manager]) }
  let(:parking_slot) { create(:parking_slot, parking_lot: parking_lot) }

  let(:valid_params) do
    {
      parking_slot: {
        name: 'ABC-123'
      }
    }
  end

  context 'success' do
    ['admin', 'town_manager'].each do |role_name|
      subject do
        put "/api/dashboard/parking_slots/#{parking_slot.id}", headers: { Authorization: get_auth_token(send(role_name)) },
        params: valid_params
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'have the same values' do
        subject
        parking_slot.reload
        expect(parking_slot.name).to eq(valid_params[:parking_slot][:name])
      end
    end
  end

  context 'fail' do
    context 'unauthorized' do
      subject do
        get "/api/dashboard/parking_slots/#{parking_slot.id}",
        params: valid_params
      end

      it_behaves_like 'response_401'
    end

    context 'insufficient permissions' do
      subject do
        put "/api/dashboard/parking_slots/#{parking_slot.id}", headers: { Authorization: get_auth_token(parking_admin) },
        params: valid_params
      end

      it_behaves_like 'response_422'

      it 'returns errors' do
        subject
        expect(json[:errors]).to be_present
      end
    end

    context 'when parking slot does not exist' do
      subject do
        get "/api/dashboard/parking_slots/9999", headers: { Authorization: get_auth_token(admin) },
        params: valid_params
      end

      it_behaves_like 'response_404'
    end
  end
end
