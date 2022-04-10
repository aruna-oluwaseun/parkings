require 'rails_helper'

RSpec.describe Api::V1::ParkingSessionsController, type: :request do
  let!(:user) { create(:user, :confirmed) }
  let!(:vehicle) { create(:vehicle, user: user) }
  let!(:parking_sessions) { create_list(:parking_session, 3, vehicle: vehicle) }

  describe 'GET #current' do
    context 'success' do
      subject do
        get '/api/v1/parking_sessions/current', headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should contains following fields' do
        subject
        [
          :id,
          :check_in,
          :check_out,
          :lot,
          :slot,
          :status,
          :total_price,
          :paid
        ].each do |a|
          expect(json.last.has_key?(a.to_s)).to eq(true)
        end
      end
    end

    describe 'GET #payment' do
      context 'success' do
        let!(:current_session) { parking_sessions.last }
        subject do
          get "/api/v1/parking_sessions/#{current_session.id}/payment",
              headers: { Authorization: get_auth_token(user) }
        end
        it_behaves_like 'response_200', :show_in_doc

        it 'contains attributes' do
          subject
          expect(json).to include(:total_time, :rate, :paid_time, :unpaid_time, :total_amount)
        end
      end
    end

    context 'fail' do
      context 'without auth token' do
        subject do
          get '/api/v1/parking_sessions/current'
        end

        it_behaves_like 'response_401', :show_in_doc
      end

      context 'no active parking session' do
        let!(:new_user) { create(:user, :confirmed) }
        let!(:new_vehicle) { create(:vehicle, user: user) }

        subject do
          subject do
            get '/api/v1/parking_sessions/current', headers: { Authorization: get_auth_token(user) }
          end

          it_behaves_like 'response_404', :show_in_doc
        end
      end
    end
  end

  describe 'GET #show' do
    context 'success' do
      subject do
        get "/api/v1/parking_sessions/#{parking_sessions.last.id}", headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc
    end

    context 'fail' do
      let!(:another_session) { create(:parking_session) }
      subject do
        get "/api/v1/parking_sessions/#{another_session.id}", headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_404', :show_in_doc
    end
  end

  describe 'GET #index' do
    context 'success' do
      subject do
        get '/api/v1/parking_sessions', headers: { Authorization: get_auth_token(user) }
      end

      it_behaves_like 'response_200', :show_in_doc

      it 'should contain 3 sessions' do
        subject
        expect(json.size).to eq(3)
      end
    end
  end

  describe 'GET #recent' do
    let!(:parking_history) { create_list(:parking_history, 5, user: user) }

    context 'success' do
      subject do
        get '/api/v1/parking_sessions/recent', headers: { Authorization: get_auth_token(user) }
      end

      it 'should contains following fields' do
        subject
        [
          :id,
          :check_in,
          :check_out,
          :lot
        ].each do |a|
          expect(json.first.with_indifferent_access.has_key?(a)).to eq(true)
        end
      end

      it_behaves_like 'response_200', :show_in_doc
    end
  end

  describe 'PUT #pay' do
    let!(:current_session) { parking_sessions.last }
    let!(:time) { Time.now.to_i + 2.hours.to_i }
    let!(:alert) { create(:alert, user: user) }

    context 'Success' do
      subject do
        put "/api/v1/parking_sessions/#{current_session.id}/pay_later", headers: { Authorization: get_auth_token(user) }, params: {
          check_out: time,
          alert_id: alert.id
        }
      end

      it 'should update check_out time' do
        subject
        current_session.reload
        alert.reload
        expect(current_session.check_out.to_i).to eq(time.to_i)
        expect(alert.resolved?).to eq(true)
      end
    end

    context 'Failure' do
      subject do
        put "/api/v1/parking_sessions/#{current_session.id}/pay_later", headers: { Authorization: get_auth_token(user) }, params: {
          check_out: time
        }
      end
      it 'should not update check_out time, because alert ID is missing' do
        subject
        alert.reload
        current_session.reload
        expect(current_session.check_out.to_i).to_not eq(time.to_i)
        expect(alert.resolved?).to eq(false)
      end
    end
  end

  describe 'POST #pay' do
    let(:current_session) { parking_sessions.last }

    subject do
      Sidekiq::Testing.fake! do
        post "/api/v1/parking_sessions/#{current_session.id}/pay", headers: { Authorization: get_auth_token(user) }
      end
    end

    it 'response wiht 201' do
      expect { subject }.to change(Payment, :count).by(1)
    end

    context 'Success' do
      let(:parking_session) { create(:parking_session, vehicle: vehicle) }
      let(:user) { create(:user, :confirmed) }
      let(:valid_params) do
        {
          check_out: DateTime.current.to_i + 2.hours,
          gateway: 'wallet'
        }
      end

      subject do
        Sidekiq::Testing.fake! do
          post "/api/v1/parking_sessions/#{parking_session.id}/pay", headers: { Authorization: get_auth_token(user) }, params: valid_params
        end
      end

      context 'when user pay using wallet' do
        context 'when parking session unpaid' do
          context 'when user has enough wallet balance' do
            before do
              @start_user_amount = user.wallet.amount
              subject
              user.reload
            end

            it 'process a succeful payment and updates wallet amount' do
              expect(Message.count).to eq(1)
              expect(Message.first.template.to_sym).to eq(:invoice)
              expect(Payment.last.payment_method).to eq('wallet')
              expect(user.wallet.amount).not_to eq(@start_user_amount)
            end
          end
        end
      end
    end

    context 'Failure' do
      let(:user) { create(:user, :confirmed) }

      let(:valid_params) do
        {
          check_out: DateTime.current.to_i + 2.hours,
          gateway: 'wallet'
        }
      end

      subject do
        Sidekiq::Testing.fake! do
          post "/api/v1/parking_sessions/#{current_session.id}/pay", headers: { Authorization: get_auth_token(user) }, params: valid_params
        end
      end

      context 'when parking session unpaid' do
        context 'when user pay using wallet' do
          context 'when user has not enough wallet balance' do
            before do
              user.wallet.update(amount: 10_00)
              @wallet_amount = user.wallet.amount
              subject
              user.reload
            end

            it 'returns error message' do
              expect(json['errors']['parkingsessions_payment'].present?).to be true
            end

            it 'doesn\'t create payment and doesn\'t update wallet amount' do
              expect(user.wallet.amount).to eq(@wallet_amount)
              expect(user.payments.blank?).to be true
              expect(Message.count).to eq(0)
            end

            it_behaves_like 'response_422', :show_in_doc
          end
        end
      end

      context 'when user pay using wallet' do
        context 'when current session has already paid' do
          before do
            current_session.update(check_in: nil)
            subject
            user.reload
          end

          it 'returns error message' do
            expect(json['errors']['parkingsessions_payment'].present?).to be true
          end

          it 'doesn\'t create payment and doesn\'t update wallet amount' do
            expect(user.payments.blank?).to be true
            expect(Message.count).to eq(0)
          end

          it_behaves_like 'response_422', :show_in_doc
        end
      end
    end
  end
end
