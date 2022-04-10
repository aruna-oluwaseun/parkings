require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingPlansController, type: :request do
  let!(:parking_lot) { create(:parking_lot, :with_admin) }
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { parking_lot.town_managers.last }
  let(:parking_admin) { parking_lot.parking_admins.last }

  before do
    2.times do
      parking_lot.parking_plans.create(file: { data: fixture_base64_file_upload('spec/files/test.jpg') } )
    end
  end

  let(:parking_plan_id) { parking_lot.parking_plans.first.id }

  describe 'DELETE #destroy' do
    context 'success' do
      %w(admin town_manager).each do |admin_account|
        context "with #{admin_account} filter" do
          subject do
            delete "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(send(admin_account)) }
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'deletes parking lot plan' do
            expect(Image.count).to eq(2)
            subject
            expect(parking_lot.parking_plans.count).to eq(1)
            expect(Image.count).to eq(1)
          end
        end
      end
    end

    context 'fail: invalid params' do
      context 'parking admin doesn\'t belong to parking lot', only: true do
        subject do
          delete "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/100", headers: { Authorization: get_auth_token(admin) }
        end
        it_behaves_like 'response_404', :show_in_doc

      end

      context 'parking admin doesn\'t belong to parking lot' do
        subject do
          delete "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans/#{parking_plan_id}", headers: { Authorization: get_auth_token(parking_admin) }
        end

        let(:parking_admin) { create(:admin, :parking_admin) }

        it_behaves_like 'response_403', :show_in_doc
      end
    end
  end
end
