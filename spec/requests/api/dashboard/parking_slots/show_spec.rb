require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingSlotsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:parking_admin) { create(:admin, role: parking_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:parking_lot) { create(:parking_lot, admins: [parking_admin, town_manager]) }
  let(:parking_slot) { create(:parking_slot, parking_lot: parking_lot) }

  context 'success' do
    subject do
      get "/api/dashboard/parking_slots/#{parking_slot.id}", headers: { Authorization: get_auth_token(admin) }
    end

    it_behaves_like 'response_200', :show_in_doc
  end

  context 'fail' do
    context 'unauthorized' do
      subject do
        get "/api/dashboard/parking_slots/#{parking_slot.id}"
      end

      it_behaves_like 'response_401'
    end

    context 'when parking slot does not exist' do
      subject do
        get "/api/dashboard/parking_slots/9999", headers: { Authorization: get_auth_token(admin) }
      end

      it_behaves_like 'response_404'
    end
  end
end
