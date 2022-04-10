require 'rails_helper'

roles_allowed_to_create = {
  super_admin: 5,
  town_manager: 4,
  parking_admin: 0,
  manager: 2,
  officer: 0
}

describe Api::Dashboard::AdminsController, type: :request do
  describe 'GET #show' do
    let!(:super_admin) { create(:admin, role: super_admin_role) }
    let!(:town_manager) { create(:admin, role: town_manager_role) }
    let!(:manager) { create(:admin, role: manager_role) }
    let!(:parking_admin) { create(:admin, role: parking_admin_role) }
    let!(:officer) { create(:admin, role: officer_role) }

    # TODO: update this spec when determinate all required specific params for eval classes
    # context 'Success when require permitted' do
    #   Api::Dashboard::DropdownsController::DROPDOWN_CLASS_LIST.each do |class_name|
    #     context "#{class_name} class_name" do
    #       subject do
    #         get "/api/dashboard/dropdowns/#{class_name}", headers: { Authorization: get_auth_token(send'super_admin') }
    #       end
    #       it_behaves_like 'response_200', :show_in_doc
    #     end
    #   end
    # end

    context 'Fails when require not permitted class name' do
      subject do
        get "/api/dashboard/dropdowns/some-strange-name", headers: { Authorization: get_auth_token(send('super_admin')) }
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    roles_allowed_to_create.each do |role, value|
      context "success with #{role} role" do
        subject do
          get "/api/dashboard/dropdowns/role_id", headers: { Authorization: get_auth_token(send(role)) }, params: { admin_id: send(role).id }
        end

        it_behaves_like 'response_200', :show_in_doc

        it "should return #{value} roles" do
          subject
          expect(json.size).to eq(value)
        end

      end
    end

    context 'Admin Role list' do

      ['manager', 'officer', 'parking_admin', 'town_manager'].each do |role_name|
        subject do
          get "/api/dashboard/dropdowns/admins_by_role-#{role_name}", headers: { Authorization: get_auth_token(send(roles_allowed_to_create.keys.sample)) }
        end

        it "should return all #{role_name}" do
          subject
          expect(json.size).to eq(Admin.send(role_name).count)
        end

      end
    end

    context "Rule's recipients search" do
      let!(:role) { :super_admin }
      let!(:new_admin) { create(:admin, email: "email.test@search.com") }
      let!(:new_admin2) { create(:admin, email: "email.search@gmail.com") }
      let!(:search_text) { "search" }

      subject do
        get "/api/dashboard/dropdowns/parking_rule-recipient", headers: { Authorization: get_auth_token(send(role)) }, params: { email: search_text }
      end

      it "Search email" do
        subject
        expect(json.size).to eq(2)
      end
    end

    context "Parking Lot's" do
      before do
        parking_lots
        get "/api/dashboard/dropdowns/parking_lot_list",
            headers: { Authorization: get_auth_token(admin) },
            params: { admin_id: admin.id }
      end

      let(:parking_lots) { create_list(:parking_lot, 2) }
      let(:role) do
        Role.find_by(name: :super_admin) || create(:role, :super_admin)
      end
      let(:admin) {  create(:admin, role: role) }
      let(:json_response) { JSON.parse(response.body) }

      it 'respond with success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
