require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingViolationsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:params) { { vehicle_id: @vehicles.first.id } }

  describe 'GET #index' do
    let(:parking_lot) { create(:parking_lot) }

    before do
      @vehicles = create_list(:vehicle, 2)
      @vehicles.each do |vehicle|
        session = create(:parking_session, vehicle: vehicle, parking_lot: parking_lot)
        vehicle_rule = create(:parking_vehicle_rule, lot: parking_lot, vehicle: vehicle)
        parking_rule = create(:parking_rule, name: ::Parking::Rule.names[:overlapping], lot: parking_lot)
        violation = create(:parking_violation, session: session, vehicle_rule: vehicle_rule, rule: parking_rule)
        create(:parking_ticket, violation: violation, status: :opened)
      end
    end

    context 'success' do
      subject do
        get "/api/dashboard/parking_lots/#{parking_lot.id}/parking_violations", params: params, headers: { Authorization: get_auth_token(admin) }
      end

      context 'when user role is admin' do
        context 'without filtering params' do

          before { subject }

          it 'returns all vehicle violations related with current parking lot' do
            expect(json.size).to eq(1)
          end
        end

        context 'with violation type filter' do
          let(:violation_type) { 'blocking_space' }
          let(:params) do
            {
              violation_type: violation_type,
              vehicle_id: @vehicles.first.id
            }
          end

          before do
            vehicle = @vehicles.first
            session = create(:parking_session, vehicle: vehicle, parking_lot: parking_lot)

            parking_rule = create(:parking_rule, name: ::Parking::Rule.names[:blocking_space], lot: parking_lot)
            @parking_violation = create(:parking_violation, session: session, vehicle_rule: vehicle.rules.first, rule: parking_rule)
            create(:parking_ticket, violation: @parking_violation, status: :opened)
            subject
          end

          it 'returns parking violations with oppropriate type' do
            expect(json.first['id']).to eq(@parking_violation.id)
            expect(json.size).to eq(1)
          end
        end

        context 'with date range filter' do
          let(:params) do
            {
              range: {
                from: '10/05/2020',
                to: '11/05/2020'
              },
              vehicle_id: @vehicles.first.id
            }
          end

          before do
            parking_sessions = @vehicles.first.parking_sessions
            @parking_violation = parking_sessions.first.violations.first
            @parking_violation.update(created_at: Time.zone.parse(params[:range][:from]))
            subject
          end

          it 'returns parking violations with oppropriate date of creation' do
            expect(json.first['id']).to eq(@parking_violation.id)
            expect(json.size).to eq(1)
          end
        end
      end

      context 'when user role is town manager' do
        before do
          get "/api/dashboard/parking_lots/#{parking_lot.id}/parking_violations", params: params, headers: { Authorization: get_auth_token(town_manager) }
        end

        context 'when user can manage parking lot' do
          it 'returns list of vehicles belonging to parking lot' do
            expect(json.size).to eq(0)
          end
        end
      end
    end

    context 'failure' do
      context 'parking lot not founded' do
        before do
          get "/api/dashboard/parking_lots/invalid_id/parking_violations", params: params, headers: { Authorization: get_auth_token(admin) }
        end

        it 'returns error message' do
          expect(json[:error].present?).to be true
        end

        it_behaves_like 'response_404', :show_in_doc
      end

      context 'unauthorized user' do
        before do
          get "/api/dashboard/parking_lots/#{parking_lot.id}/parking_violations", params: params
        end

        it_behaves_like 'response_401'
      end
    end
  end
end
