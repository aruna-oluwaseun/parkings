require 'rails_helper'

describe Build::UserWalletsBuilder do
  describe '#call' do
    subject { ::Build::UserWalletsBuilder.new.call }

    context 'when users have not wallets' do
      before do
        users = create_list(:user, 3)
        Wallet.destroy_all
        subject
      end

      it 'creates wallet for each user' do
        expect(Wallet.count).to eq(3)
      end
    end

    context 'when users already have wallets' do
      before do
        users = create_list(:user, 3)
      end

      it 'do not create user wallets' do
        expect { subject }.to change(Wallet, :count).by(0)
      end
    end
  end
end
