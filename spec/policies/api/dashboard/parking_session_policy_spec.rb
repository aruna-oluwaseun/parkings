require 'rails_helper'

describe Api::Dashboard::ParkingSessionPolicy do
  subject { policy.apply(action) }

  let(:policy) { described_class.new(parking_session, user: user) }
  let(:parking_lot) { create(:parking_lot, :with_admin) }
  let(:parking_operator) { parking_lot.parking_admins.last }
  let(:town_manager) { parking_lot.town_managers.last }
  let(:parking_session) { create(:parking_session, parking_lot: parking_lot) }

  describe '#show?' do
    let(:action) { :show? }

    context 'town manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :town_manager) }

        it { is_expected.to be_falsey }
      end
    end

    context 'parking operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :parking_admin) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
