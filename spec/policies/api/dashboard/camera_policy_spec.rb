require 'rails_helper'

describe Api::Dashboard::CameraPolicy do
  subject { policy.apply(action) }

  let(:policy) { described_class.new(camera, user: user) }
  let(:parking_lot) { create(:parking_lot, :with_admin) }
  let(:camera) { create(:camera, parking_lot: parking_lot) }
  let(:parking_operator) { parking_lot.parking_admins.last }
  let(:town_manager) { parking_lot.town_managers.last }

  describe '#show?' do
    let(:action) { :show? }
    let(:user) { parking_operator }

    it { is_expected.to be_truthy }

    context 'forbidden' do
      let(:user) { create(:admin) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#update?' do
    let(:action) { :update? }

    context 'parking operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_falsey }
    end

    context 'town manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }
    end
  end

  describe '#destroy?' do
    let(:action) { :destroy? }

    context 'parking operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_falsey }
    end

    context 'town manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }
    end
  end
end
