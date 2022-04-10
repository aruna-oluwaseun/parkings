require 'rails_helper'

RSpec.describe WalletRechargePayment, type: :model do
  describe 'creating wallet recharge payment' do
    let(:user) { create(:user) }

    context 'with valid payment method' do
      subject { WalletRechargePayment.new(payment_method: payment_method, user_id: user.id) }

      context 'with cash payment method' do
        let(:payment_method) { :cash }

        it { is_expected.to be_valid }
      end

      context 'with credit_card payment method' do
        let(:payment_method) { :credit_card }

        it { is_expected.to be_valid }
      end

      context 'with free_pay payment method' do
        let(:payment_method) { :free_pay }

        it { is_expected.to be_valid }
      end
    end
  end
end
