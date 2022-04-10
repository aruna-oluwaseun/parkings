require 'rails_helper'

RSpec.describe Api::Dashboard::AdminsController, type: :request do
  describe 'POST #create' do
    let!(:admin) { create(:admin, role: super_admin_role) }
    let(:valid_params) do
      {
        admin: {
          email: Faker::Internet.email,
          username: Faker::Admin.username,
          status: 'active',
          avatar: fixture_base64_file_upload('spec/files/test.jpg'),
          phone: Faker::Phone.number,
          role_id: manager_role.id,
          name: Faker::Name.first_name,
        },
        role_type: role_type
      }
    end
    let(:invalid_params) do
      {
        admin: {
          email: 'invalid',
          username: '',
          phone: '+1',
          role_id: Role.second.id,
          name: 'Paul',
          status: '11111'
        },
        role_type: 'town_manager'
      }
    end
    let(:json_response) { JSON.parse(response.body) }

    context 'success' do
      subject do
        post '/api/dashboard/admins', headers: { Authorization: get_auth_token(admin) }, params: valid_params
      end

      let(:role_type) { 'town_manager' }

      it_behaves_like 'response_201', :show_in_doc

      it 'should create new record' do
        subject
        expect(json_response.dig('id')).not_to be_blank
      end

      it 'should send email' do
        expect(AdminMailer).to receive(:user_created)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        expect(AdminMailer).to receive(:welcome_letter)
          .and_return( double("AdminMailer", deliver_later: true) ).once
        subject
      end
    end

    context 'fail: invalid params' do
      subject do
        post '/api/dashboard/admins', headers: { Authorization: get_auth_token(admin) }, params: invalid_params
      end

      it_behaves_like 'response_422', :show_in_doc
    end

    context 'fail: access denied' do
      subject do
        post '/api/dashboard/admins', headers: { Authorization: get_auth_token(manager) }, params: valid_params
      end

      let!(:manager) { create(:admin, role: manager_role) }
      let(:role_type) { 'super_admin' }

      it_behaves_like 'response_403'

      it 'return error' do
        subject
        expect(json_response['error']).not_to be_blank
      end
    end
  end
end
