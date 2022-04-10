require 'rails_helper'

RSpec.describe Api::Dashboard::NotificationsController, type: :request do
  describe 'PUT #update' do
    let!(:user) { create(:user) }
    let!(:admin) { create(:admin, role: super_admin_role) }
    let!(:user_notification) { create(:user_notification, user: user) }

    context 'success: by admin' do
      subject do
        put "/api/dashboard/notifications/#{user_notification.id}",
        headers: { Authorization: get_auth_token(admin) },
        params: {
          text: 'Vehicle with LPN aaa-1337'
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'updates body of notification' do
        subject
        user_notification.reload
        expect(user_notification.text).to eq('Vehicle with LPN aaa-1337')
      end
    end
  end
end
