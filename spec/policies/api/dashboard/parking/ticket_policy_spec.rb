require 'rails_helper'

describe Api::Dashboard::Parking::TicketPolicy do
  subject { policy.apply(action) }

  let(:policy) { described_class.new(ticket, user: user) }
  let(:agency) { create(:agency, :with_officer, :with_manager) }
  let(:ticket) { create(:parking_ticket, agency: agency) }

  describe '#update?' do
    let(:action) { :update? }

    describe 'manager' do
      let(:user) { agency.managers.last }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :manager) }

        it { is_expected.to be_falsey }
      end
    end

    describe 'officer' do
      let(:user) { agency.officers.last }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :officer) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#show?' do
    let(:action) { :show? }

    describe 'manager' do
      let(:user) { agency.managers.last }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :officer) }

        it { is_expected.to be_falsey }
      end
    end

    describe 'officer' do
      let(:user) { agency.officers.last }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :officer) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
