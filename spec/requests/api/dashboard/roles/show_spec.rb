require 'rails_helper'

RSpec.describe Api::Dashboard::RolesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #show' do
    context 'success' do
      subject do
        get "/api/dashboard/roles/#{Role.first.id}", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          get "/api/dashboard/roles/#{Role.last.id}"
        end

        it_behaves_like 'response_401'
      end

      context 'When role does not exists' do
        subject do
          get '/api/dashboard/roles/1000', headers: { Authorization: get_auth_token(admin) }
        end

        it_behaves_like 'response_404'
      end
    end
  end
end
