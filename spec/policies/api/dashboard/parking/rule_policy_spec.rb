require 'rails_helper'

describe Api::Dashboard::Parking::RulePolicy do
  subject { policy.apply(:update?) }

  let(:policy) { described_class.new(rule, user: user) }

  describe '#update?' do
    let(:parking_lot) { create(:parking_lot, :with_rules, :with_admin) }
    let(:rule) { parking_lot.rules.last }
    let(:user) { parking_lot.parking_admins.last }

    it { is_expected.to be_truthy }

    context 'forbidden' do
      let(:user) { create(:admin, :parking_admin) }

      it { is_expected.to be_falsey }
    end
  end
end
