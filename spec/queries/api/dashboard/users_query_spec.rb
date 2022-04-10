require 'rails_helper'

RSpec.describe Api::Dashboard::UsersQuery, type: :query do
  describe 'Search users with scope' do
    let(:admin) { create(:admin, role: super_admin_role) }
    let(:suspended_users) { create_list(:user, 5, status: :suspended) }
    let(:active_users) { create_list(:user, 5, status: :active) }
    let!(:users) { suspended_users + active_users }

    subject do
      ::Api::Dashboard::UsersQuery.call(params.merge(current_user: admin))
    end

    context 'when a range of dates is present' do
      let(:params) do
        {
          range: {
            from: Time.now.utc.to_date.strftime("%Y-%-m-%-d"),
            to: Time.now.utc.to_date.strftime("%Y-%-m-%-d")
          }
        }
      end

      it 'returns 10 items' do
        expect(subject.size).to eq(10)
      end
    end

    context 'when a query string is included' do
      context 'when first_name is used' do
        let(:params) do
          {
            query: {
              users: {
                first_name: users.last.first_name[0..-2]
              }
            }
          }
        end

        it 'returns the matched user' do
          expect(subject.size).to eq(1)
          expect(subject.take).to eq(users.last)
        end
      end

      context 'when last_name is used' do
        let(:params) do
          {
            query: {
              users: {
                last_name: users.last.last_name[0..-2]
              }
            }
          }
        end

        it 'returns the matched user' do
          expect(subject.size).to eq(1)
          expect(subject.take).to eq(users.last)
        end
      end

      context 'when email is used' do
        let(:params) do
          {
            query: {
              users: {
                email: users.last.email[0..-2]
              }
            }
          }
        end

        it 'returns the matched user' do
          expect(subject.size).to eq(1)
          expect(subject.take).to eq(users.last)
        end
      end
    end

    context 'when order attributes are present' do
      let(:params) do
        {
          order: {
            keyword: 'id',
            direction: 'desc'
          }
        }
      end

      it 'returns the results in the right order' do
        expect(subject.pluck(:id)).to eq(::User.order(id: :desc).pluck(:id))
      end
    end

    context 'when order attributes are empty' do
      let(:params) do
        {
          order: {
            keyword: nil,
            direction: nil
          }
        }
      end

      it 'returns the results in the default order' do
        expect(subject.pluck(:id)).to eq(::User.pluck(:id))
      end
    end
  end
end
