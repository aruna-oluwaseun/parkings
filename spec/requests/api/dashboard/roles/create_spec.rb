require 'rails_helper'

RSpec.describe Api::Dashboard::RolesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:valid_params) do
    {
      role: {
        name: 'Dispute manager',
        permissions:
        [
          {
            name: 'Dispute',
            record_create: true,
            record_read: true,
            record_update: true,
            record_delete: true
          }
        ]
      }
    }
  end

  let(:invalid_params) do
    {
      role: {
        name: 'Test manager',
        permissions:
        [
          {
            name: 'Dispute',
            record_create: false,
            record_read: false,
            record_update: false,
            record_delete: false
          }
        ]
      }
    }
  end

  describe 'POST #create' do
    context 'success' do
      subject do
        post '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) },
        params: valid_params
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'saves the manually created role' do
        subject
        expect(Role.count).to be(6)
      end

      it 'haves the same values' do
        subject
        json_permissions = json[:permissions].first
        params_permissions = valid_params[:role][:permissions].first

        expect(json[:name]).to eq(valid_params[:role][:name])
        expect(json_permissions[:name]).to eq(params_permissions[:name])
        expect(json_permissions[:record_create]).to eq(params_permissions[:record_create])
        expect(json_permissions[:record_read]).to eq(params_permissions[:record_read])
        expect(json_permissions[:record_update]).to eq(params_permissions[:record_update])
        expect(json_permissions[:record_delete]).to eq(params_permissions[:record_delete])
      end
    end

    context 'fail' do
      context 'no permission defined' do
        let(:valid_params) do
          {
            role: {
              name: 'Dispute manager',
              permissions:
              [
                {
                  name: 'Dispute',
                  record_create: false,
                  record_read: false,
                  record_update: false,
                  record_delete: false
                },
                {
                  name: 'Admin',
                  record_create: false,
                  record_read: false,
                  record_update: false,
                  record_delete: false
                }
              ]
            }
          }
        end

        let(:json_response) { JSON.parse response.body }

        subject do
          post '/api/dashboard/roles',
          headers: { Authorization: get_auth_token(admin) },
          params: valid_params
        end

        it_behaves_like 'response_422'

        it 'returns error' do
          subject
          expect(json_response.dig('errors', 'permissions')).to include('Atleast 1 permission should be defined')
        end
      end

      context 'unauthorized' do
        subject do
          post '/api/dashboard/roles',
          params: valid_params
        end

        it_behaves_like 'response_401'
      end

      context 'When a invalid permission name is present' do
        subject do
          valid_params[:role][:permissions].first[:name] = 'very_weird_name'
          post '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) },
          params: valid_params
        end

        it_behaves_like 'response_422'

        it 'returns a error message' do
          subject
          expect(json[:errors][:permission].first).to eq('Invalid permission name, please try a new one.')
        end
      end

      context 'When the permissions array is not present' do
        subject do
          valid_params[:role][:permissions] = nil
          post '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) },
          params: valid_params
        end

        it_behaves_like 'response_422'

        it 'returns a error message' do
          subject
          expect(json[:errors][:permissions].first).to eq('Permissions is required')
        end
      end

      context 'When the role name is not present' do
        subject do
          valid_params[:role][:name] = nil
          post '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) },
          params: valid_params
        end

        it_behaves_like 'response_422'

        it 'returns a error message' do
          subject
          expect(json[:errors][:name].first).to eq('Name is required')
        end
      end

      context 'When the role name is taken' do
        subject do
          valid_params[:role][:name] = 'town_manager'
          post '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) },
          params: valid_params
        end

        it_behaves_like 'response_422'

        it 'returns a error message' do
          subject
          expect(json[:errors][:display_name].first).to be_present
        end
      end

      context 'When no attribute is selected' do
        subject do
          valid_params[:role][:name] = 'tester_name'
          post '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) },
          params: invalid_params
        end

        it_behaves_like 'response_422'

      end
    end
  end
end
