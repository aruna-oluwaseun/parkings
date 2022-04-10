require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingSessionsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:parking_session) { create(:parking_session) }
  let(:town_manager) { create(:admin, role: town_manager_role) }

  describe 'GET #show' do
    subject do
      get "/api/dashboard/parking_sessions/#{parking_session.id}/logs", headers: { Authorization: get_auth_token(admin) }
    end

    context 'success' do
      context 'when user role is admin' do
        before { subject }

        it_behaves_like 'response_200', :show_in_doc

        it 'returns list of parking session logs' do
          expect(json.size).to eq(1)
        end

        it 'returns parking session logs with pagination' do
          expect(response.headers['X-Total']).to eq(parking_session.logs.size.to_s)
          expect(response.headers['X-Per-Page']).to eq('10')
        end
      end

      context 'when user role is not admin' do
        subject do
          get "/api/dashboard/parking_sessions/#{parking_session.id}/logs", headers: { Authorization: get_auth_token(town_manager) }
        end

        before { subject }

        it 'returns empty list' do
          expect(json['error']).to be_present
        end
      end

      context 'with filtering params' do
        let(:params) do
          {
            range: {
              from: '10/05/2020',
              to: '11/05/2020'
            }
          }
        end

        subject do
          get "/api/dashboard/parking_sessions/#{parking_session.id}/logs", headers: { Authorization: get_auth_token(admin) }, params: params
        end

        before do
          parking_session.logs.first.update(created_at: Time.zone.parse(params[:range][:from]))
          parking_session.confirmed!
          subject
        end

        it 'returns parking session logs according to params' do
          expect(json.size).to eq(1)
        end
      end
    end

    context 'failure' do
      context 'session doesnt exist' do
        subject do
          get "/api/dashboard/parking_sessions/ivalid_id/logs", headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404', :show_in_doc
      end

      context 'unauthorized user' do
        subject do
          get "/api/dashboard/parking_sessions/#{parking_session.id}/logs"
        end

        it_behaves_like 'response_401'
      end
    end
  end
end
