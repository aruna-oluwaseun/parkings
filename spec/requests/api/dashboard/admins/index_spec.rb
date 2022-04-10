require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'GET #index' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let!(:suspended_users) { create_list(:admin, 5, role: manager_role, status: :suspended) }
    let!(:manager) { create(:admin, role: manager_role) }
    let!(:active_users) { create_list(:admin, 5, role: officer_role, status: :active, parking_lots: [create(:parking_lot)]) }
    let(:users) { suspended_users + active_users }

    context 'success' do
      subject do
        get '/api/dashboard/admins', headers: { Authorization: get_auth_token(admin) }
      end
      let!(:more_users) { create_list(:admin, 20, role: manager_role, status: :suspended) }

      it_behaves_like 'response_200', :show_in_doc

      it 'should have 20 users per request' do
        subject
        expect(json.size).to eq(20)
      end
    end

    context 'success: filter by query' do
      let(:field) { [:name, :email, :username].sample }
      let(:query) { { "#{field}": users.find { |u| u.active? && u.role_id == officer_role.id }.public_send(field).last(2) } }

      subject do
        get '/api/dashboard/admins', headers: { Authorization: get_auth_token(admin) }, params: {
          status: :active,
          role_id: officer_role.id,
          query: query,
          order: { keyword: 'admins.email', asc: true }
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should respond with filtred users' do
        subject
        expect(json.size < 20).to eq(true)
        expect(json.map { |u| u['role']['id'] }.uniq.sample ).to eq(officer_role.id)
        expect(json.map { |u| u['status'] }.uniq.sample ).to eq('active')
        expect(json.map { |u| u['name'].include?(query[field]) || u['email'].include?(query[field]) || u['username'].include?(query[field]) }.include?(false)).to eq(false)
      end
    end

    context "success: manager can only see it's officers" do
      subject do
        get '/api/dashboard/admins', headers: { Authorization: get_auth_token(manager) }
      end

      let(:manager) { create(:admin, :manager) }
      let(:agencies) { create_list(:agency, 5, :with_officer, managers: [manager]) }
      let!(:expectation) { agencies.map(&:officers).flatten.size }

      it 'it returns officers' do
        subject
        expect(json.size).to eq(expectation)
      end
    end

    context 'success: officer should not see any users' do
      subject do
        get '/api/dashboard/admins', headers: { Authorization: get_auth_token(officer) }
      end

      let(:agencies) { create_list(:agency, 5, :with_officer, managers: [manager]) }
      let(:officer) { create(:admin, :officer) }

      before do
        agencies.each do |agency|
          agency.officers << officer
        end
      end

      it 'should respond with all officers' do
        subject
        expect(json.size).to eq(0)
      end
    end

    context 'success: town_manager should see agency officer and parking lot operators under its managed parking lots' do
      subject do
        get '/api/dashboard/admins', headers: { Authorization: get_auth_token(town_manager) }
      end

      let(:town_manager) { create(:admin, :town_manager) }
      let(:parking_lots) { create_list(:parking_lot, 5, :with_agency, :with_admin, town_managers: [town_manager]) }
      let!(:expectation) do
        [
          parking_lots.map(&:agency).map(&:officers),
          parking_lots.map(&:parking_admins)
        ].flatten.compact.size
      end

      it 'should return parking lots operators' do
        subject
        expect(json.size).to eq(expectation)
      end
    end
  end
end
