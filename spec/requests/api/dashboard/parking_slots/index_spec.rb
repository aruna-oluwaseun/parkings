require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingSlotsController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:parking_admin) { create(:admin, role: parking_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:parking_lot) { create(:parking_lot, admins: [parking_admin, town_manager]) }
  let!(:parking_slots) { create_list(:parking_slot, 10, parking_lot: parking_lot) }

  context 'success' do
    subject do
      get "/api/dashboard/parking_lots/#{parking_lot.id}/parking_slots", headers: { Authorization: get_auth_token(admin) }
    end

    it_behaves_like 'response_200', :show_in_doc

    it 'should return all slots' do
      subject
      expect(json.count).to eq(parking_slots.size)
    end
  end
end
