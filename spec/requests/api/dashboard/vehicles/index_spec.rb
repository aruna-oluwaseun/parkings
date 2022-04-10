require 'rails_helper'

RSpec.describe Api::Dashboard::VehiclesController, type: :request do
  let!(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #index' do
    context 'success: by super_admin' do
      subject do
        get '/api/dashboard/vehicles', headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should return all vehicles' do
        subject
        expect(json.size).to eq(Vehicle.count)
      end
    end
  end
end
