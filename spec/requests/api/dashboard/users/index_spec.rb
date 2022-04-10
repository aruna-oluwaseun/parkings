require 'rails_helper'

RSpec.describe Api::Dashboard::UsersController, type: :request do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:town_manager) { create(:admin, role: town_manager_role) }
  let(:suspended_users) { create_list(:user, 5, status: :suspended) }
  let(:active_users) { create_list(:user, 5, status: :active) }

  let!(:users) { suspended_users + active_users }

  before { create(:role_permission, :full, role: town_manager_role, name: 'User') }

  describe 'GET #index' do
    context 'success' do
      context 'with allowed roles' do
        ['admin', 'town_manager'].each do |role_name|
          subject do
            get '/api/dashboard/users', headers: { Authorization: get_auth_token(send(role_name)) }
          end

          it_behaves_like 'response_200', :show_in_doc

          it 'returns 10 items' do
            subject
            expect(json.size).to be(10)
          end
        end
      end

      context 'when a range of dates is present' do
        subject do
          get '/api/dashboard/users', headers: { Authorization: get_auth_token(admin) },
          params: {
            range: {
              from: Time.now.utc.to_date.strftime("%Y-%-m-%-d"),
              to: Time.now.utc.to_date.strftime("%Y-%-m-%-d")
            }
          }
        end

        it_behaves_like 'response_200', :show_in_doc
      end

      context 'when both dates are empty' do
        subject do
          get '/api/dashboard/users', headers: { Authorization: get_auth_token(admin) },
          params: {
            range: {
              from: nil,
              to: nil
            }
          }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'returns 10 items' do
          subject
          expect(json.size).to eq(10)
        end
      end

      context 'when query is included' do
        subject do
          get '/api/dashboard/users', headers: { Authorization: get_auth_token(admin) },
          params: {
            query: {
              users: {
                first_name: users.first.first_name[0..-2]
              }
            }
          }
        end

        it_behaves_like 'response_200', :show_in_doc

        it 'returns 1 item' do
          subject
          expect(json.size).to eq(1)
          expect(json.first["first_name"]).to eq(users.first.first_name)
        end
      end

      context 'when order attributes are present' do
        subject do
          get '/api/dashboard/users', headers: { Authorization: get_auth_token(admin) },
          params: {
            order: {
              keyword: 'id',
              direction: 'desc'
            }
          }
        end

        it_behaves_like 'response_200', :show_in_doc
      end

      context 'when order attributes are empty' do
        subject do
          get '/api/dashboard/users', headers: { Authorization: get_auth_token(admin) },
          params: {
            order: {
              keyword: nil,
              direction: nil
            }
          }
        end

        it_behaves_like 'response_200', :show_in_doc
      end
    end

    context 'fail: unauthorized' do
      subject do
        get '/api/dashboard/users'
      end

      it 'returns unauthorized error' do
        subject
        expect(json[:error]).to eq('Unauthorized')
      end

      it_behaves_like 'response_401'
    end
  end
end
