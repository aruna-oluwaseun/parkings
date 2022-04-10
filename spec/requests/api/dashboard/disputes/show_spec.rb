require 'rails_helper'

RSpec.describe Api::Dashboard::DisputesController, type: :request do
  subject do
    get "/api/dashboard/disputes/#{dispute.id}", headers: { Authorization: get_auth_token(admin) }
  end

  describe 'GET #show' do
    context 'super admin' do
      let(:admin) { create(:admin, role: super_admin_role) }
      let(:dispute) { create(:dispute) }
      it_behaves_like 'response_200', :show_in_doc
    end

    context 'town_manager' do
      let(:lot) { create(:parking_lot) }
      let(:dispute) { create(:dispute, parking_session: create(:parking_session, parking_lot: lot)) }
      let(:admin) { create(:admin, role: town_manager_role) }

      before do
        lot.town_managers << admin
      end

      it_behaves_like 'response_200'
    end
  end
end
