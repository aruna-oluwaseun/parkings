require 'rails_helper'

RSpec.describe Api::Dashboard::AgencyTypesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let!(:agency_type) { create(:agency_type) }

  describe 'GET #delete' do
    context 'success' do
      context 'when user role is super admin' do
        context 'when agency type is not assigned to an agency' do
          subject do
            delete "/api/dashboard/agency_types/#{agency_type.id}", headers: { Authorization: get_auth_token(admin) }
          end

          it 'deletes agency type' do
            expect { subject }.to change(AgencyType, :count).by(-1)
          end
        end
      end
    end

    context 'fail' do
      context 'when unauthorized user' do
        before do
          delete "/api/dashboard/agency_types/#{agency_type.id}"
        end

        it_behaves_like 'response_401', :show_in_doc

        it 'returns unauthorized error message' do
          expect(json[:error].present?).to be true
        end
      end

      context 'when user role is not super admin' do
        let(:town_manager) { create(:admin, role: town_manager_role) }

        before do
          delete "/api/dashboard/agency_types/#{agency_type.id}", headers: { Authorization: get_auth_token(town_manager) }
        end

        it_behaves_like 'response_403', :show_in_doc

        it 'returns error message' do
          expect(json[:error]).to eq('You don\'t have permissions to process that action')
        end
      end

      context 'when user role is user admin' do
        context 'when agency type is assigned to an agency' do
          let(:agency_type) { create(:agency_type) }

          before do
            create(:agency, agency_type_id: agency_type.id)
            delete "/api/dashboard/agency_types/#{agency_type.id}", headers: { Authorization: get_auth_token(admin) }
          end

          it_behaves_like 'response_422', :show_in_doc

          it 'does not delete agency type' do
            expect(json[:errors][:agency_type].present?).to be true
          end
        end

        context 'and name is in default types' do
          let(:default_agency_type) { create(:agency_type, :with_default_name) }

          before do
            delete "/api/dashboard/agency_types/#{default_agency_type.id}", headers: { Authorization: get_auth_token(admin) }
          end

          it_behaves_like 'response_422', :show_in_doc

          it 'does not delete agency type' do
            expect(json[:errors][:agency_type].first).to eq(I18n.t 'active_interaction.errors.models.agency_types/delete.attributes.agency_type.cannot_be_deleted')
          end
        end
      end
    end
  end
end
