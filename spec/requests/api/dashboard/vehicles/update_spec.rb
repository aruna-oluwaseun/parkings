require 'rails_helper'

RSpec.describe Api::Dashboard::VehiclesController, type: :request do
  let!(:parking_session) { create(:parking_session) }
  let!(:vehicle) { create(:vehicle) }
  let!(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #update' do
    subject do
      put "/api/dashboard/vehicles/#{parking_session.id}",
          headers: { Authorization: get_auth_token(admin) },
          params: {
            parking_session: {
              status: 'finished',
            }
          }
    end

    it_behaves_like 'response_200', :show_in_doc
  end
end
