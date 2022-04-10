require 'rails_helper'

RSpec.describe Api::Dashboard::UsersController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:user) { create(:user, status: :active) }

  before { create(:role_permission, :full, role: town_manager_role, name: 'User') }

  describe 'GET #show' do
    context 'success' do
      context 'with allowed roles' do
        ['admin', 'town_manager'].each do |role_name|
          subject do
            get "/api/dashboard/users/#{user.id}", headers: { Authorization: get_auth_token(send(role_name)) }
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'returns the same id' do
            subject
            expect(json["id"]).to eq(user.id)
          end
        end
      end
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          get "/api/dashboard/users/#{user.id}"
        end

        it 'returns unauthorized error' do
          subject
          expect(json[:error]).to eq('Unauthorized')
        end

        it_behaves_like 'response_401'
      end

      context 'when user does not exist' do
        subject do
          get "/api/dashboard/users/10000", headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404'
      end
    end
  end
end
