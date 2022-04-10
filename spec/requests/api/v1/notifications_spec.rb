require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :request do
  let!(:user) { create(:user, :confirmed, :with_vehicles) }
  let!(:notifications) { create_list(:user_notification, 30, user: user) }
  let!(:read_notifications) { create_list(:user_notification, 30, user: user, status: :read) }
  let(:random_notification_ids) { notifications.shuffle.last(10).map(&:id) }

  describe 'GET #index' do
    before do
      create_list(:user_notification, 10, user: user, template: :car_parked)
    end

    context 'success 200' do
      subject do
        get '/api/v1/notifications', headers: { Authorization: get_auth_token(user) }, params: {
          type: :car_parked,
          vehicle_id: user.vehicles.first.id
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should has valid attributes' do
        subject
        attributes = %w(id title text read created_at parking_session_id parking_session_id
                        plate_number minutes_extended parking_slot_number violation_id violation_type
                        citation_id wallet_remaining_ballance)

        attributes.each do |attr|
          expect(json.first.has_key?(attr)).to be_truthy
        end
      end

      it 'should not has invalid attribute' do
        subject
        expect(json.first['unknown']).to be(nil)
      end

      it 'should has an id' do
        subject
        expect(json.first['id']).to be_present
      end

      it 'should has a title' do
        subject
        expect(json.first['title']).to be_present
      end

      it 'should has a text' do
        subject
        expect(json.first['text']).to be_present
      end

      it 'should has a created_at' do
        subject
        expect(json.first['created_at']).to be_present
      end

      it 'should has a parking_session_id' do
        subject
        expect(json.first['parking_session_id']).to be_present
      end

      it 'should has a plate_number' do
        subject
        expect(json.first['plate_number']).to be_present
      end

      it 'should has a parking_slot_number' do
        subject
        expect(json.first['parking_slot_number']).to be_present
      end

      context 'select random notification ids' do
        subject do
          get '/api/v1/notifications', headers: { Authorization: get_auth_token(user) }, params: {
            ids: random_notification_ids
          }
        end

        it 'return array contains all notification data' do
          subject
          expect(json.size).to eq(random_notification_ids.count)
        end
      end
    end

    context 'success with types and statuses' do
      subject do
        get '/api/v1/notifications', headers: { Authorization: get_auth_token(user) }, params: {
          type: @types,
          status: @statuses,
        }
      end

      it 'should not throw any error if template or status does not exist' do
        @statuses = ['non_exists, new', 'test']
        @types = ['non_exists, new', 'test']
        subject
        expect(json.size).to eq(0) # It should return 0 because any nothification exists
      end
    end

    context 'success with types and statuses' do
      subject do
        get '/api/v1/notifications', headers: { Authorization: get_auth_token(user) }, params: {
          type: @types,
          status: @statuses,
        }
      end

      it 'should filter by types and statuses', :show_in_doc do
        @statuses = [User::Notification.statuses.keys.sample, User::Notification.statuses.keys.sample]
        @types = [User::Notification.templates.keys.sample]
        count = User::Notification.where(template: @types).count
        subject
        expect(json.size).to eq(count)
      end
    end

  end

  describe 'GET #types' do
    context 'success' do

      subject do
        get '/api/v1/notifications/types', headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc

    end
  end

  describe 'GET #read' do
    context 'success' do
      subject do
        get '/api/v1/notifications/read', headers: { Authorization: get_auth_token(user) }, params: {
          page: 3,
          per_page: 5
        }
      end

      it 'response has TOTAL headers' do
        subject
        expect(response.headers['X-Total']).to eq('30')
        expect(response.headers['X-Page']).to eq('3')
        expect(response.headers['X-Per-Page']).to eq('5')
        expect(json.size).to eq(5)
      end

      it 'notifications has valid status' do
        subject
        expect(json.first['read']).to eq(true)
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

  describe 'PUT #read' do
    context 'success' do
      subject do
        put '/api/v1/notifications/read', headers: { Authorization: get_auth_token(user) }, params: {
          notification_ids: notifications.map(&:id)
        }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'Change status attributes to read' do
        subject do
          expect(notifications.map(&:read?)).to all(be_truthy)
        end
      end
    end
  end

  describe 'GET #unread' do
    context 'success' do
      subject do
        get '/api/v1/notifications/unread', headers: { Authorization: get_auth_token(user) }
      end

      it 'notifications has valid status' do
        subject
        expect(json.first['read']).to eq(false)
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

  describe 'PUT #update' do
    let(:notification) { notifications.last }

    context 'success' do
      subject do
        put "/api/v1/notifications/#{notification.id}", headers: { Authorization: get_auth_token(user) }
      end

      it 'should update notification' do
        expect(notification.reload.read?).to eq(false)
        subject
        expect(notification.reload.read?).to eq(true)
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      context 'unauthorized' do
        subject do
          put "/api/v1/notifications/#{notification.id}"
        end

        it_behaves_like 'response_401'
      end
    end
  end
end
