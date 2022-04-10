require 'rails_helper'

RSpec.describe Api::Dashboard::RolesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #index' do
    context 'success: by super_admin' do
      subject do
        get '/api/dashboard/roles', headers: { Authorization: get_auth_token(admin) }, params: params
      end

      context 'without order params' do
        let(:params) { {} }

        before do
          subject
          @sorted_role_ids = Role.order('created_at desc').pluck(:id)
          @response_ids = json.map { |role| role['id'] }
        end

        it 'returns roles list in descending order' do
          expect(@response_ids).to eq(@sorted_role_ids)
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

          before do
            subject
            @sorted_role_ids = Role.order('id asc').pluck(:id)
            @response_ids = json.map { |role| role['id'] }
          end

          it 'returns roles list sorted by id in ascending order' do
            expect(@response_ids).to eq(@sorted_role_ids)
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

          before do
            subject
            @sorted_role_ids = Role.order('name desc').pluck(:id)
            @response_ids = json.map { |role| role['id'] }
          end

          it 'returns roles list sorted by name in descending order' do
            expect(@response_ids).to eq(@sorted_role_ids)
          end
        end
      end
    end
  end
end
