require 'rails_helper'

RSpec.describe Api::Dashboard::VehiclesParkingSessionsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:parking_lot) { create(:parking_lot, admins: [admin]) }
  let(:vehicle) { create(:vehicle) }

  describe 'GET #show' do
    context 'success' do
      before do
        create_list(:parking_session, 5, vehicle: vehicle, parking_lot: parking_lot)
      end

      context 'when user role is admin' do
        before do
          get "/api/dashboard/vehicles/#{vehicle.id}/parking_sessions", headers: { Authorization: get_auth_token(admin) }
        end

        it 'returns list of vehicle parking detailes' do
          expect(json.size).to eq(5)
        end

        it_behaves_like 'response_200', :show_in_doc
      end

      context 'when user is town manager' do
        let(:town_manager) { create(:admin, role: town_manager_role) }

        before do
          get "/api/dashboard/vehicles/#{vehicle.id}/parking_sessions", headers: { Authorization: get_auth_token(town_manager) }
        end

        it 'returns list of vehicle parking details belongin to town manager' do
          expect(json.empty?).to be true
        end

      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          get "/api/dashboard/vehicles/#{vehicle.id}/parking_sessions"
        end

        it_behaves_like 'response_401'
      end

      context 'when vehicle not founded' do
        subject do
          get "/api/dashboard/vehicles/invalid_id/parking_sessions"
        end

        it_behaves_like 'response_401'
      end
    end
  end
end
