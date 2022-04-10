require 'rails_helper'

RSpec.describe Api::Dashboard::RolesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #permissions_available' do
    context 'success: by super_admin' do
      subject do
        get '/api/dashboard/permissions/permissions_available', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end
end
