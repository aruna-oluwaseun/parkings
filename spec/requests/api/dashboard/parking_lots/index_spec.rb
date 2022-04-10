require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingLotsController, type: :request do
  let!(:lots) { create_list(:parking_lot, 2) }
  let(:admin) { create(:admin, role: super_admin_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:new_parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:lot_3) { create(:parking_lot, admins: [parking_admin, town_manager]) }
  let!(:lot_4) { create(:parking_lot, admins: [town_manager]) }
  let(:response_ids) { json.map { |lot| lot['id'] } }

  describe 'GET #index' do
    context 'success: by super_admin' do
      subject do
        get '/api/dashboard/parking_lots', headers: { Authorization: get_auth_token(admin) }, params: params
      end

      context 'without order params' do
        let(:params) { {} }
        let(:sorted_parking_ids) { ParkingLot.order('created_at desc').pluck(:id) }

        before do
          subject
        end

        it 'returns parking lots list in descending order' do
          expect(response_ids).to eq(sorted_parking_ids)
        end
      end

      context 'with order params' do
        context 'with id sorting parameter' do
          let(:params) do
            {
              order: {
                keyword: 'id',
                direction: 'asc'
              }
            }
          end

          let(:sorted_parking_ids) { ParkingLot.order('id asc').pluck(:id) }

          before do
            subject
          end

          it 'returns parking lots list sorted by id in ascending order' do
            expect(response_ids).to eq(sorted_parking_ids)
          end
        end

        context 'with name sorting parameter' do
          let(:params) do
            {
              order: {
                keyword: 'name',
                direction: 'desc'
              }
            }
          end

          let(:sorted_parking_ids) { ParkingLot.order('name desc').pluck(:id) }

          before do
            subject
          end

          it 'returns roles list sorted by name in descending order' do
            expect(response_ids).to eq(sorted_parking_ids)
          end
        end

        context 'with full address sorting parameter' do
          let(:params) do
            {
              order: {
                keyword: 'locations.full_address',
                direction: 'asc'
              }
            }
          end

          let(:sorted_parking_ids) { ParkingLot.joins(:location).order('full_address asc').pluck(:id) }

          before do
            subject
          end

          it 'returns parking list sorted by full address in descending order' do
            expect(response_ids).to eq(sorted_parking_ids)
          end
        end

        context 'with town manager sorting parameter' do
          let(:params) do
            {
              order: {
                keyword: 'town_manager',
                direction: 'asc'
              }
            }
          end

          let(:sorted_role_ids) { ParkingLot.all.includes(:admins).sort { |a, b| a.town_manager.name <=> b.town_manager.name }.pluck(:id) }

          before do
            subject
          end

          it 'returns roles list sorted by full address in descending order' do
            expect(response_ids).to eq(sorted_role_ids)
          end
        end
      end
    end
  end
end
