require 'rails_helper'

describe Api::Dashboard::ParkingLotPolicy do
  subject { policy.apply(action) }

  let(:policy) { described_class.new(parking_lot, user: user) }
  let(:parking_lot) { create(:parking_lot, :with_admin) }
  let(:parking_operator) { parking_lot.parking_admins.last }
  let(:town_manager) { parking_lot.town_managers.last }

  describe '#show?' do
    let(:action) { :show? }

    context 'town_manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :town_manager) }

        it { is_expected.to be_falsey }
      end
    end

    context 'parking_operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :manager) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#update?' do
    let(:action) { :update? }

    context 'town_manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :town_manager) }

        it { is_expected.to be_falsey }
      end
    end

    context 'parking_operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :manager) }

        it { is_expected.to be_falsey }
      end
    end
  end
end