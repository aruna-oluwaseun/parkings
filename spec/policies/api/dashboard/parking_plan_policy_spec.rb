require 'rails_helper'

describe Api::Dashboard::ParkingPlanPolicy do
  subject { policy.apply(action) }

  # ParkingPlanPolicy is authorized thru parking lot
  # Please check app/controllers/api/dashboard/parking_plans_controller.rb
  let(:policy) { described_class.new(parking_lot, user: user) }
  let(:parking_lot) { create(:parking_lot, :with_admin, :with_parking_plans) }
  let(:parking_plan) { parking_lot.parking_plans.last }
  let(:town_manager) { parking_lot.town_managers.last }
  let(:parking_operator) { parking_lot.parking_admins.last }

  describe "#show" do
    let(:action) { :show? }

    context 'parking operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :parking_admin) }

        it { is_expected.to be_falsey }
      end
    end

    context 'town manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :town_manager) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#create" do
    let(:action) { :create? }

    context 'parking operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_falsey }
    end

    context 'town manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :town_manager) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#update" do
    let(:action) { :update? }

    context 'parking operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_falsey }
    end

    context 'town manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :town_manager) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#destroy" do
    let(:action) { :destroy? }

    context 'parking operator' do
      let(:user) { parking_operator }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :parking_admin) }

        it { is_expected.to be_falsey }
      end
    end

    context 'town manager' do
      let(:user) { town_manager }

      it { is_expected.to be_truthy }

      context 'forbidden' do
        let(:user) { create(:admin, :town_manager) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
