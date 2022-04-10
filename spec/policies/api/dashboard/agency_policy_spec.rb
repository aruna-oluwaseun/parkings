require 'rails_helper'

describe Api::Dashboard::AgencyPolicy do
  subject { policy.apply(action) }

  let(:policy) { described_class.new(agency, user: user) }
  let(:agency) { create(:agency, :with_manager, :with_officer) }
  let(:manager) { agency.manager }
  let(:officer) { agency.officers.last }

  describe '#show?' do
    let(:action) { :show? }

    context 'manager' do
      let(:user) { manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin) }

        it { is_expected.to be_falsey }
      end
    end

    context 'officer' do
      let(:user) { officer }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :officer) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#update?' do
    let(:action) { :update? }

    context 'manager' do
      let(:user) { manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin) }

        it { is_expected.to be_falsey }
      end
    end

    context 'officer' do
      let(:user) { officer }

      it { is_expected.to be_falsey }

      context 'forbidden' do
        let(:user) { create(:admin, :officer) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
