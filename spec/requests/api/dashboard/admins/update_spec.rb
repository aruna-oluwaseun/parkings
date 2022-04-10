require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'PUT #update' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let!(:manager) { create(:admin, role: manager_role) }
    let!(:officer) { create(:admin, role: officer_role) }

    let(:payload) do
      {
        admin: {
          email: Faker::Internet.email,
          username: Faker::Admin.username,
          status: 'suspended',
          phone: Faker::Phone.number,
          role_id: manager_role.id,
          name: Faker::Name.first_name,
        },
        role_type: 'parking_lot_manager'
      }
    end

    context 'success: by admin' do
      subject do
        put "/api/dashboard/admins/#{manager.id}", headers: { Authorization: get_auth_token(admin) }, params: payload
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail: invalid params' do
      subject do
        put "/api/dashboard/admins/#{manager.id}",
            headers: { Authorization: get_auth_token(admin) },
            params: {
              admin: payload[:admin]
            }
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    context 'fail: role type is empty' do
      let!(:another_manager) { create(:admin, role: manager_role) }
      subject do
        put "/api/dashboard/admins/#{manager.id}", headers: { Authorization: get_auth_token(another_manager) }
      end

      it_behaves_like 'response_422'
    end
  end
end
