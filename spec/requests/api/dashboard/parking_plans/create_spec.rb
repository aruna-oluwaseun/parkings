require 'rails_helper'

RSpec.describe Api::Dashboard::ParkingPlansController, type: :request do
  let!(:parking_lot) { create(:parking_lot, :with_admin) }
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { parking_lot.town_managers.last }
  let(:parking_admin) { parking_lot.parking_admins.last }

  let(:parking_plan_name) { 'Plan name' }

  let(:valid_params) do
    {
      parking_plan_image: fixture_base64_file_upload('spec/files/test.jpg'),
      name: parking_plan_name
    }
  end

  describe 'POST #create' do
    context 'success' do

      subject do
        post "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans", headers: { Authorization: get_auth_token(admin) }, params: valid_params
      end

      it_behaves_like 'response_201', :show_in_doc

      it 'saves parking lot plan' do
        expect { subject }.to change(Image,:count).by(1)
        parking_lot.reload
        expect(parking_lot.parking_plans.count).to eq(1)
        expect(parking_lot.parking_plans.first.meta_name).to eq(parking_plan_name)
      end

      it 'expects a presence of name to parking lot plan' do
        subject
        expect(parking_lot.parking_plans.first.meta_name).to be_present
      end

      %w(town_manager admin).each do |admin_account|
        context "with #{admin_account}" do
          subject do
            post "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans", headers: { Authorization: get_auth_token(send(admin_account)) }, params: valid_params
          end

          it_behaves_like 'response_201', :show_in_doc

          it 'saves parking lot plan' do
            expect { subject }.to change(Image,:count).by(1)
            parking_lot.reload
            expect(parking_lot.parking_plans.count).to eq(1)
            expect(parking_lot.parking_plans.first.meta_name).to eq(parking_plan_name)
          end
        end
      end
    end

    context 'fail: invalid params' do
      context 'parking admin doesn\'t belong to parking lot' do
        subject do
          post "/api/dashboard/parking_lots/#{parking_lot.id}/parking_plans", headers: { Authorization: get_auth_token(parking_admin) }, params: valid_params
        end

        let(:parking_admin) { create(:admin, :parking_admin) }

        it_behaves_like 'response_403', :show_in_doc
      end
    end
  end
end
