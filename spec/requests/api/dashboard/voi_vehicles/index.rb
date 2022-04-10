require 'rails_helper'

RSpec.describe Api::Dashboard::VoiVehiclesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }

  describe 'GET #index' do
    let(:parking_lot) { create(:parking_lot, admins: [town_manager]) }

    context 'success' do
      subject do
        get '/api/dashboard/voi_vehicles', params: params, headers: { Authorization: get_auth_token(admin) }
      end

      before do
        2.times do
          vehicle = create(:vehicle)
          session = create(:parking_session, vehicle: vehicle, parking_lot: parking_lot)
          vehicle_rule = create(:parking_vehicle_rule, lot: parking_lot, vehicle: vehicle)
          violation = create(:parking_violation, session: session, vehicle_rule: vehicle_rule)
          create(:parking_ticket, violation: violation, status: :opened)
        end
        subject
      end

      context 'when user role is admin' do
        context 'without filtering params' do
          let(:params) { { parking_lot_id: parking_lot.id } }

          it 'returns all vehicles with violations on current parking lot' do
            expect(json.size).to eq(2)
          end

          context 'with plate number filter' do
            let(:plate_number) { Vehicle.first.plate_number }
            let(:params) do
              { plate_number: plate_number }
            end

            it 'returns vehicle with oppropriate plate number' do
              expect(json.size).to eq(1)
            end
          end
        end
      end

      context 'when user role is town manager' do
        let(:params) { { parking_lot_id: parking_lot.id } }

        before do
          get '/api/dashboard/voi_vehicles', params: params, headers: { Authorization: get_auth_token(town_manager) }
        end

        context 'when user can manage parking lot' do
          it 'returns list of vehicles belonging to parking lot' do
            expect(json.size).to eq(2)
          end
        end
      end
    end

    context 'failure' do
      context 'parking lot not founded' do
        let(:params) { { parking_lot_id: 'invalid_id' } }

        before do
          get '/api/dashboard/voi_vehicles', params: params, headers: { Authorization: get_auth_token(admin) }
        end

        it 'returns error message' do
          expect(json[:error].present?).to be true
        end

        it_behaves_like 'response_404', :show_in_doc
      end

      context 'unauthorized user' do
        let(:params) { { parking_lot_id: parking_lot.id } }

        before do
          get '/api/dashboard/voi_vehicles', params: params
        end

        it_behaves_like 'response_401'
      end
    end
  end
end
