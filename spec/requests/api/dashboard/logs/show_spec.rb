require 'rails_helper'

RSpec.describe Api::Dashboard::LogsController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #show' do
    subject do
      get "/api/dashboard/logs/session_logs", headers: { Authorization: get_auth_token(admin) }
    end

    it_behaves_like 'response_200', :show_in_doc
  end
end
