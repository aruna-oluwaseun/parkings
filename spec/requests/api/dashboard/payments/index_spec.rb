require 'rails_helper'

RSpec.describe Api::Dashboard::PaymentsController, type: :request do
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:super_admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }
  let!(:session) { create(:parking_session, check_out: nil) }

  describe 'GET #index' do
    before do
      create_list(:payment, 2, status: 1)
      create_list(:payment, 2, status: 2)
    end
    context "town manager's disputes" do
      subject do
        get "/api/dashboard/payments", headers: { Authorization: get_auth_token(town_manager) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'returns 4 payments' do
        subject
        expect(json.size).to eq(4)
      end
    end

    context 'pending Payments' do
      subject do
        get "/api/dashboard/payments",
            headers: { Authorization: get_auth_token(super_admin) },
            params: { status: 2 }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'returns 2 pending Payments' do
        subject
        expect(json.size).to eq(2)
      end
    end

    context 'Successful Payments' do
     subject do
       get "/api/dashboard/payments",
           headers: { Authorization: get_auth_token(super_admin) },
           params: { status: 1 }
     end

     it_behaves_like 'response_200', :show_in_doc

     it 'returns 2 Successful Payments' do
       subject
       expect(json.size).to eq(2)
     end
   end

    context 'Filter by Amount' do
      let!(:payment) { create(:payment, amount:50.0) }
      subject do
        get "/api/dashboard/payments",
            headers: { Authorization: get_auth_token(super_admin) },
            params: { amount: payment.amount }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'Filter by First Name' do
      subject do
        get "/api/dashboard/payments",
            headers: { Authorization: get_auth_token(super_admin) },
            params: { first_name: session.user.first_name }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'Filter by plate_number' do
      subject do
        get "/api/dashboard/payments",
            headers: { Authorization: get_auth_token(super_admin) },
            params: { plate_number: session.vehicle.plate_number }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'Filter by Parking Lot Name' do
      subject do
        get "/api/dashboard/payments",
            headers: { Authorization: get_auth_token(super_admin) },
            params: { name: session.parking_lot.name }
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

  describe 'Sorting #index' do
    let(:params) {}

    subject do
      get '/api/dashboard/payments',
      headers: { Authorization: get_auth_token(admin) },
      params: params
    end

    context 'Sort by created at' do
      let(:admin) { create(:admin, role: super_admin_role) }
      let(:payment3) {create(:payment, status: :pending, amount: 80, created_at: 2.days.ago)}

      before do
        payment1 = create(:payment, id: 100,  status: :pending, created_at: 2.days.ago)
        payment2 = create(:payment, id: 101, status: :pending, created_at: Time.now)
      end

      context 'sorting asc' do
        let(:params) { { "order[keyword]": "payments.created_at", "order[direction]": "asc" } }

        it 'returns payments sorted by created at' do
          subject
          expect(json.first["id"]).to eq(100)
        end
      end

      context 'sorting desc' do
        let(:params) { { "order[keyword]": "payments.created_at", "order[direction]": "desc" } }

        it 'returns payments sorted by created at' do
          subject
          expect(json.first["id"]).to eq(101)
        end
      end
    end

    context 'Sort by amount' do
      let(:admin) { create(:admin, role: super_admin_role) }
      let(:payment3) {create(:payment, status: :pending, amount: 80, created_at: 2.days.ago)}

      before do
        payment1 = create(:payment, status: :pending, amount: 30, created_at: 2.days.ago)
        payment2 = create(:payment, status: :pending, amount: 80, created_at: Time.now)
      end

      context 'sorting asc' do
        let(:params) { { "order[keyword]": "payments.amount", "order[direction]": "asc" } }

        it 'returns payments sorted by amount' do
          subject
          expect(json.first["amount"].to_i).to eq(30)
        end
      end

      context 'sorting desc' do
        let(:params) { { "order[keyword]": "payments.amount", "order[direction]": "desc" } }

        it 'returns payments sorted by amount' do
          subject
          expect(json.first["amount"].to_i).to eq(80)
        end
      end
    end
  end
end
