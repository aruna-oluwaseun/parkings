require 'rails_helper'

RSpec.describe Api::Dashboard::AgencyTypesController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }

  describe 'GET #index' do
    context 'success' do
      subject do
        get '/api/dashboard/agency_types', headers: { Authorization: get_auth_token(admin) }, params: { per_page: per_page }
      end

      context 'when user super admin' do
        context 'with pagination params' do
          let(:per_page) { 10 }

          before do
            create_list(:agency_type, 10)
            subject
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'returns all agency types' do
            expect(response.headers['X-Total']).to eq(AgencyType.count.to_s)
            expect(response.headers['X-Per-Page']).to eq(per_page.to_s)
          end
        end

        context 'with order params by name in descending' do
          subject do
            get('/api/dashboard/agency_types',
                headers: { Authorization: get_auth_token(admin) },
                params: { order: { keyword: 'name', direction: 'desc' } })
          end

          before do
            create_list(:agency_type, 5)
            subject
          end

          it 'return right ordered list' do
            expect(AgencyType.pluck(:name).sort!.reverse).to eq(json.map { |el| el['name'] })
          end
        end
      end
    end

    context 'fail' do
      context 'when unauthorized user' do
        before do
          get '/api/dashboard/agency_types'
        end

        it_behaves_like 'response_401', :show_in_doc

        it 'returns unauthorized error message' do
          expect(json[:error].present?).to be true
        end
      end

      context 'when user role is not super admin' do
        let(:town_manager) { create(:admin, role: town_manager_role) }

        before do
          get '/api/dashboard/agency_types', headers: { Authorization: get_auth_token(town_manager) }
        end

        it_behaves_like 'response_403', :show_in_doc

        it 'returns error message' do
          expect(json[:error]).to eq('You don\'t have permissions to process that action')
        end
      end
    end
  end
end
