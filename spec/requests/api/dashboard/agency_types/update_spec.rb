require 'rails_helper'

RSpec.describe Api::Dashboard::AgencyTypesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:agency) { create(:agency) }
  let(:agency_type_params) do
    { agency_type: { name: 'State police' } }
  end

  describe 'PUT #update' do
    let(:agency_type) { create(:agency_type) }

    context 'success' do
      subject do
        put "/api/dashboard/agency_types/#{agency_type.id}", headers: { Authorization: get_auth_token(admin) }, params: agency_type_params
      end

      before do
        subject
        agency_type.reload
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'updates agency type' do
        expect(agency_type.name).to eq(agency_type_params[:agency_type][:name])
        expect(json[:name]).to eq(agency_type_params[:agency_type][:name])
      end
    end

    context 'fail' do
      context 'when unauthorized user' do
        before do
          put "/api/dashboard/agency_types/#{agency_type.id}", params: agency_type_params
        end

        it_behaves_like 'response_401', :show_in_doc

        it 'returns unauthorized error message' do
          expect(json[:error].present?).to be true
        end
      end

      context 'when user role is not super admin' do
        let(:town_manager) { create(:admin, role: town_manager_role) }

        before do
          put "/api/dashboard/agency_types/#{agency_type.id}", headers: { Authorization: get_auth_token(town_manager) }, params: agency_type_params
        end

        it_behaves_like 'response_403', :show_in_doc

        it 'returns error message' do
          expect(json[:error]).to eq('You don\'t have permissions to process that action')
        end
      end

      context 'when name parameter is empty' do
        let(:invalid_params) do
          { agency_type: { name: '' } }
        end

        before do
          put "/api/dashboard/agency_types/#{agency_type.id}", headers: { Authorization: get_auth_token(admin) }, params: invalid_params
        end

        it_behaves_like 'response_422', :show_in_doc

        it 'returns error message' do
          expect(json[:errors][:name].present?).to be true
        end
      end
    end
  end
end
