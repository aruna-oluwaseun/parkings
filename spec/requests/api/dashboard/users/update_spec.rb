require 'rails_helper'

RSpec.describe Api::Dashboard::UsersController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:user) { create(:user, status: :active) }

  before { create(:role_permission, :full, role: town_manager_role, name: 'User') }

  describe 'PUT #update' do
    context 'success' do
      context 'when status is present' do
        ['admin', 'town_manager'].each do |role_name|
          subject do
            put "/api/dashboard/users/#{user.id}", headers: { Authorization: get_auth_token(send(role_name)) }, params: {
              user: {
                status: 'suspended'
              }
            }
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'updates the user status' do
            subject
            user.reload
            expect(user.status).to eq('suspended')
          end
        end
      end

      context 'when dev flag is present' do
        subject do
          put "/api/dashboard/users/#{user.id}", headers: { Authorization: get_auth_token(admin) }, params: {
            user: {
              is_dev: true
            }
          }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'updates the user as dev' do
          subject
          user.reload
          expect(user.is_dev).to be(true)
        end
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          put "/api/dashboard/users/#{user.id}", params: {
            user: {
              status: 'suspended'
            }
          }
        end

        it 'returns unauthorized error' do
          subject
          expect(json[:error]).to eq('Unauthorized')
        end

        it_behaves_like 'response_401'
      end

      context 'when the dev flag is used by a non-admin user' do
        subject do
          put "/api/dashboard/users/#{user.id}", headers: { Authorization: get_auth_token(town_manager) }, params: {
            user: {
              is_dev: true
            }
          }
        end

        it_behaves_like 'response_422'

        it 'return errors' do
          subject
          expect(json[:errors][:dev]).to be_present
        end
      end

      context 'when user does not exist' do
        subject do
          put "/api/dashboard/users/10000", headers: { Authorization: get_auth_token(admin) }, params: {
            user: {
              status: 'suspended'
            }
          }
        end

        it_behaves_like 'response_404'
      end
    end
  end
end
