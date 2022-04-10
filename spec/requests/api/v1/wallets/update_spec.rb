require 'rails_helper'

RSpec.describe  Api::V1::WalletsController, type: :request do
  describe 'PUT #update' do
    let(:user) { create(:user, :confirmed) }
    let(:amount) { 100 }

    context 'success payment' do
      subject do
        put '/api/v1/user/wallet', headers: { Authorization: get_auth_token(user) },
            params: payment_params.with_indifferent_access
      end

      let(:payment_params) do
        {
          gateway_params: {
            production: 0,
            set_credit_card_as_default: '1',
            credit_card_attributes: {
              number: '4111111111111111',
              cvv: '112',
              holder_name: 'TESTUSER',
              expiration_year: 2022,
              expiration_month: 12,
              should_store: 0
            },
            billing_address: {
              address1: '123 MAIN STREET',
              city: 'New-York',
              country_code: 'US',
              state_code: 'NY',
              postal_code: '55555'
            },
            amount: amount
          }
        }
      end

      context 'without using digital wallet' do
        context 'without saving credit card' do
          before do
            subject
            user.reload
            @wallet_recharge_payment = user.wallet_recharge_payments.last
          end

          it 'updates user wallet' do
            expect(user.wallet.amount).to eq(200_00)
          end

          it 'creates wallet recharge payment' do
            expect(@wallet_recharge_payment.amount).to eq(100_00)
            expect(@wallet_recharge_payment.status).to eq('success')
          end

          it 'doesn\'t save user credit card' do
            expect(user.credit_cards.empty?).to be true
          end
        end

        context 'with saving credit card credit card' do
          subject do
            put '/api/v1/user/wallet', headers: { Authorization: get_auth_token(user) },
                params: payment_params.with_indifferent_access
          end

          before do
            payment_params[:gateway_params][:credit_card_attributes][:should_store] = 1
            @payment_params = payment_params
            subject
          end

          it 'saves credit card' do
            expect(user.credit_cards.size).to eq(1)
          end
        end

        context 'with a card already associated to user account' do
          let(:credit_card) { create(:credit_card, user: user) }

          let(:payment_params) do
            {
              gateway_params: {
                production: 0,
                credit_card_id: credit_card.id,
                credit_card_attributes: {
                  cvv: '112'
                },
                amount: amount
              }
            }
          end

          before do
            subject
          end

          it 'process a succeful payment with cardconnect and updates user wallet' do
            expect(user.wallet_recharge_payments.last.amount).to eq(amount * 100)
          end
        end
      end
    end

    context 'fail payment' do
      subject do
        put '/api/v1/user/wallet', headers: { Authorization: get_auth_token(user) },
            params: payment_params.with_indifferent_access
      end

      context 'with invalid card expiration date' do
        let(:payment_params) do
          {
            gateway_params: {
              production: 0,
              set_credit_card_as_default: '1',
              credit_card_attributes: {
                number: '4387751111111038',
                cvv: '112',
                holder_name: 'TESTUSER',
                expiration_year: 12,
                expiration_month: 12,
                should_store: 0
              },
              billing_address: {
                address1: '123 MAIN STREET',
                city: 'New-York',
                country_code: 'US',
                state_code: 'NY',
                postal_code: '55555'
              },
              amount: amount
            }
          }
        end

        before do
          subject
        end

        it 'return error message and process failed wallet recharge payment with cardconnect due to invalid date' do
          expect(json['error'].present?).to be true
          expect(user.wallet_recharge_payments.any?).to be true
          expect(user.wallet_recharge_payments.last.status).to eq('failed')
        end
      end

      context 'with invalid card number' do
        let(:payment_params) do
          {
            gateway_params: {
              production: 0,
              set_credit_card_as_default: '1',
              credit_card_attributes: {
                number: 'invalid_card_number',
                cvv: '112',
                holder_name: 'TESTUSER',
                expiration_year: 2020,
                expiration_month: 12,
                should_store: 0
              },
              amount: amount
            }
          }
        end

        before { subject }

        it 'does\'t process any payment with cardconnect due to invalid number format when tokenizing' do
          expect(json['error'].present?).to be true
          expect(user.wallet_recharge_payments.any?).to be false
        end
      end
   end
  end
end
