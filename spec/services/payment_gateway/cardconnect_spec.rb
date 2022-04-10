require 'rails_helper'

describe PaymentGateway::Cardconnect do
  let(:user) { create(:user) }
  let(:amount) { 100_00 }
  let(:payment_gateway) { described_class.new(user, payment_params) }

  describe '#payment_method' do
    subject { payment_gateway.send(:payment_method) }

    context 'PAY_WITH_CC' do
      let(:payment_params) do
        {
          credit_card_attributes: {
            number: '4788250000121443',
            cvv: '112',
            holder_name: 'Test name',
            expiration_year: '23',
            expiration_month: '12',
            should_store: '0'
          },
          amount: amount
        }
      end

      it { is_expected.to eq 'PAY_WITH_CC' }
    end

    context 'digital_wallet' do
      let(:last_digits) { '1234' }
      let(:payment_params) do
        {
          digital_wallet_attributes: {
            encryptionhandler: digital_wallet,
            devicedata: ''
          },
          last_credit_card_digits: last_digits
        }
      end

      context 'EC_GOOGLE_PAY_CC' do
        let(:digital_wallet) { 'EC_GOOGLE_PAY' }
        it { is_expected.to eq 'EC_GOOGLE_PAY_CC' }
      end

      context 'EC_APPLE_PAY_CC' do
        let(:digital_wallet) { 'EC_APPLE_PAY' }
        it { is_expected.to eq 'EC_APPLE_PAY_CC' }
      end

      context 'EC_GOOGLE_PAY' do
        let(:last_digits) { nil }
        let(:digital_wallet) { 'EC_GOOGLE_PAY' }
        it { is_expected.to eq 'EC_GOOGLE_PAY' }
      end

      context 'EC_APPLE_PAY' do
        let(:last_digits) { nil }
        let(:digital_wallet) { 'EC_APPLE_PAY' }
        it { is_expected.to eq 'EC_APPLE_PAY' }
      end
    end
  end
end
