require 'rails_helper'

RSpec.describe Api::Dashboard::VehiclesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }
  let(:vehicle) { create(:vehicle) }
  let!(:parking_session) { create(:parking_session) }

  describe 'GET #show' do
    subject do
      get "/api/dashboard/vehicles/#{vehicle.id}", headers: { Authorization: get_auth_token(admin) }
    end

    it_behaves_like 'response_200', :show_in_doc
  end
end
