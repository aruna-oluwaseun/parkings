require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'creating wallet' do
    context 'initilaize' do
      subject { Wallet.new }

      it 'sets amount to 0.0' do
        expect(subject.amount).to eq(0.0)
      end
    end

    it 'has valid factory' do
      wallet = create(:wallet)
      expect(wallet).to be_valid
      expect(wallet.amount).to be_present
      expect(wallet.user).to be_present
    end
  end
end
