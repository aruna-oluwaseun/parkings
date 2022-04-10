require 'rails_helper'

describe Api::Dashboard::DisputePolicy do
  subject { policy.apply(action) }

  let(:policy) { described_class.new(dispute, user: user) }
  let(:dispute) { create(:dispute) }
  let(:parking_lot) { dispute.parking_session.parking_lot }
  let(:town_manager) { parking_lot.town_managers.last }
  let(:parking_operator) { create(:admin, :parking_admin) }
  let(:dispute_officer) { dispute.admin }

  before do
    parking_lot.parking_admins << parking_operator
  end

  describe '#show?' do
    let(:action) { :show? }

    context 'town_manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }
    end

    context 'parking_operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_falsey }
    end
  end
end
