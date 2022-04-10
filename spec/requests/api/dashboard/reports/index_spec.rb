require 'rails_helper'

RSpec.describe Api::Dashboard::ReportsController, type: :request do
  let!(:town_manager) { create(:admin, role: town_manager_role) }
  let!(:parking_admin) { create(:admin, role: parking_admin_role) }
  let!(:super_admin) { create(:admin, role: super_admin_role) }
  let!(:lot) { create(:parking_lot) }
  let!(:session) { create(:parking_session, check_out: nil) }
  let!(:agency) { create(:agency) }

  before do
    create_list(:report, 2, name: "Report Wunsch", type: ParkingLot.first)
  end

  describe 'GET #index' do
    context "town manager's disputes" do
      subject do
        get "/api/dashboard/reports", headers: { Authorization: get_auth_token(town_manager) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'returns 2 reports' do
        subject
        expect(json.size).to eq(2)
      end
    end
  end

  describe 'Sorting report' do
    let(:params) {}

    subject do
      get '/api/dashboard/reports',
      headers: { Authorization: get_auth_token(admin) },
      params: params
    end


    context 'Sort by name' do
      let(:admin) { create(:admin, role: super_admin_role) }

      before do
        report1 = create(:report, name: "Report Wunsch", type: ParkingLot.first)
        report2 = create(:report, name: "Agency Wunsch", type: Agency.first)
      end
      context 'sorting asc' do
        let(:params) { { "order[keyword]": "reports.name", "order[direction]": "asc" } }

        it 'returns corresponding report name' do
          subject
          expect(json.first["name"]).to eq("Agency Wunsch")
        end
      end

      context 'sorting desc' do
        let(:params) { { "order[keyword]": "reports.name", "order[direction]": "desc" } }

        it 'returns corresponding report name' do
          subject
          expect(json.first["name"]).to eq("Report Wunsch")
        end
      end
    end

    context 'Sort by type' do
      let(:admin) { create(:admin, role: super_admin_role) }

      before do
        report1 = create(:report, name: "Lot at Wunsch", type: ParkingLot.first)
        report2 = create(:report, name: "Robert Wunsch", type: Agency.first)
      end
      context 'sorting asc' do
        let(:params) { { "order[keyword]": "reports.type_type", "order[direction]": "asc" } }

        it 'returns corresponding report name' do
          subject
          expect(json.first["type_name"]).to eq("Agency")
        end
      end

      context 'sorting desc' do
        let(:params) { { "order[keyword]": "reports.type_type", "order[direction]": "desc" } }

        it 'returns corresponding report name' do
          subject
          expect(json.first["type_name"]).to eq("Parking lot")
        end
      end
    end

    context 'Sort by created at' do
      let(:admin) { create(:admin, role: super_admin_role) }

      before do
        report1 = create(:report, name: "Lot at Wunsch", type: ParkingLot.first)
        report2 = create(:report, name: "Robert Wunsch", type: Agency.first, created_at: 2.days.ago)
      end
      context 'sorting asc' do
        let(:params) { { "order[keyword]": "reports.created_at", "order[direction]": "asc" } }

        it 'returns corresponding report name' do
          subject
          expect(json.first["name"]).to eq("Robert Wunsch")
        end
      end

      context 'sorting desc' do
        let(:params) { { "order[keyword]": "reports.created_at", "order[direction]": "desc" } }

        it 'returns corresponding report name' do
          subject
          expect(json.first["name"]).to eq("Lot at Wunsch")
        end
      end
    end
  end
end
