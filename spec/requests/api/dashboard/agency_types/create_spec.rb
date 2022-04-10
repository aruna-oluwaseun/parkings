require 'rails_helper'

RSpec.describe Api::Dashboard::AgencyTypesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:agency_type_params) do
    {
      agency_type: {
        name: 'State police'
      }
    }
  end

  describe 'POST #create' do
    context 'success' do
      subject do
        post '/api/dashboard/agency_types', headers: { Authorization: get_auth_token(admin) }, params: agency_type_params
      end

      context 'when user role is super admin' do
        context 'with valid params' do
          it_behaves_like 'response_201', :show_in_doc

          it 'creates a new agency type' do
            expect { subject }.to change(AgencyType, :count).by(1)
          end
        end
      end
    end

    context 'fail' do
      context 'when unauthorized user' do
        before do
          post '/api/dashboard/agency_types', params: agency_type_params
        end

        it_behaves_like 'response_401', :show_in_doc

        it 'returns unauthorized error message' do
          expect(json[:error].present?).to be true
        end
      end

      context 'when name parameter is empty' do
        let(:invalid_params) do
          { agency_type: { name: '' } }
        end

        before do
          post '/api/dashboard/agency_types', headers: { Authorization: get_auth_token(admin) }, params: invalid_params
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'returns errors message' do
          expect(json[:errors][:name].present?).to be true
        end
      end

      context 'when user role is not super admin' do
        let(:town_manager) { create(:admin, role: town_manager_role) }

        before do
          post '/api/dashboard/agency_types', headers: { Authorization: get_auth_token(town_manager) }, params: agency_type_params
        end

        it_behaves_like 'response_403', :show_in_doc

        it 'returns error message' do
          expect(json[:error]).to eq('You don\'t have permissions to process that action')
        end
      end
    end
  end
end
