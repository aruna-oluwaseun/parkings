require 'rails_helper'
include ActionView::Helpers::NumberHelper

describe Statistics::VehiclesCurrentlyParked do
  let(:params) { {} }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:superadmin) { create(:admin, :superadmin) }
  let(:town_manager) { create(:admin, :town_manager) }
  let(:parking_admin) { create(:admin, :parking_admin) }
  let(:parking_admin_two) { create(:admin, :parking_admin) }

  let(:superadmin_parking_lots) { create_list(:parking_lot, 5, admins: [superadmin]) }
  let(:town_manager_parking_lots) { create_list(:parking_lot, 3, admins: [town_manager]) }
  let(:parking_admin_parking_lots) { create_list(:parking_lot, 2, admins: [parking_admin]) }
  let(:parking_admin_two_parking_lots) { create_list(:parking_lot, 2, admins: [parking_admin_two]) }

  let(:interaction_superadmin) do
    described_class.run(params.merge(current_user: superadmin))
  end

  let(:interaction_town_manager) do
    described_class.run(params.merge(current_user: town_manager))
  end

  let(:interaction_parking_admin) do
    described_class.run(params.merge(current_user: parking_admin))
  end

  let(:superadmin_parking_session_today) do
    lots = superadmin_parking_lots
    create_list(
      :parking_session, 5,
      status: [:confirmed, :created].sample,
      parking_lot: lots.delete_at(rand(lots.length))
    )
  end

  let(:town_manager_parking_session_today) do
    lots = town_manager_parking_lots
    create_list(
      :parking_session, 3,
      status: [:confirmed, :created].sample,
      parking_lot: lots.delete_at(rand(lots.length))
    )
  end

  let(:parking_admin_parking_session_today) do
    lots = parking_admin_parking_lots
    create_list(
      :parking_session, 2,
      status: [:confirmed, :created].sample,
      parking_lot: lots.delete_at(rand(lots.length))
    )
  end

  context 'Requested by super_admin user' do
    subject { interaction_superadmin.result }

    before do
      superadmin_parking_session_today
      town_manager_parking_session_today
      parking_admin_parking_session_today
    end

    let(:expectation) do
      total_sessions_today_count = superadmin_parking_session_today.count +
                                   town_manager_parking_session_today.count +
                                   parking_admin_parking_session_today.count
      {
        title: I18n.t('interactions.statistics.currently_parked'),
        disable_date_range: true,
        range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
        result: I18n.t('interactions.statistics.parked_now', count: number_with_delimiter(total_sessions_today_count))
      }
    end

    it { is_expected.to eq expectation }

    context 'With selected parking lots' do
      before do
        create_list(
          :parking_session, 5,
          status: [:confirmed, :created].sample,
          parking_lot: superadmin_parking_lots.last
        )
        create_list(
          :parking_session, 3,
          status: [:confirmed, :created].sample,
          parking_lot: town_manager_parking_lots.last,
        )
        create_list(
          :parking_session, 2,
          status: [:confirmed, :created].sample,
          parking_lot: parking_admin_parking_lots.last,
        )
      end

      let(:parking_lot_ids) do
        [
          superadmin_parking_lots.last.id,
          town_manager_parking_lots.last.id,
          parking_admin_parking_lots.last.id
        ]
      end

      let(:params) do
        {
          parking_lot_ids: parking_lot_ids
        }
      end

      it "return parked vehicle" do
        expect(subject.dig(:result)).to eq I18n.t('interactions.statistics.parked_now', count: 10)
      end
    end
  end

  context 'Requested by town_manager user' do
    subject { interaction_town_manager.result }

    before do
      superadmin_parking_session_today
      town_manager_parking_session_today
      parking_admin_parking_session_today
    end

    let(:expectation) do
      total_sessions_today_count = superadmin_parking_session_today.count +
        town_manager_parking_session_today.count +
        parking_admin_parking_session_today.count
      {
        title: I18n.t('interactions.statistics.currently_parked'),
        disable_date_range: true,
        range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
        result: I18n.t('interactions.statistics.parked_now', count: number_with_delimiter(total_sessions_today_count))
      }
    end

    it { is_expected.to eq expectation }

    context 'with selected parking lots' do
      before do
        create_list(
          :parking_session, 4,
          status: [:confirmed, :created].sample,
          parking_lot: superadmin_parking_lots.first
        )
        create_list(
          :parking_session, 2,
          status: [:confirmed, :created].sample,
          parking_lot: town_manager_parking_lots.last,
        )
        create_list(
          :parking_session, 1,
          status: [:confirmed, :created].sample,
          parking_lot: parking_admin_parking_lots.first,
        )
      end

      let(:parking_lot_ids) do
        [
          superadmin_parking_lots.first.id,
          town_manager_parking_lots.last.id,
          parking_admin_parking_lots.first.id
        ]
      end

      let(:params) do
        {
          parking_lot_ids: parking_lot_ids
        }
      end

      it "return parked vehicle" do
        expect(subject.dig(:result)).to eq I18n.t('interactions.statistics.parked_now', count: 7)
      end
    end
  end

  context 'Requested by parking_admin user' do
    subject { interaction_parking_admin.result }

    before do
      superadmin_parking_session_today
      parking_admin_parking_session_today
    end

    let(:expectation) do
      {
        title: I18n.t('interactions.statistics.currently_parked'),
        disable_date_range: true,
        range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
        result: I18n.t(
          'interactions.statistics.parked_now',
          count: number_with_delimiter(parking_admin_parking_session_today.count)
        )
      }
    end

    it { is_expected.to eq expectation }

    context 'with selected parking lots' do
      before do
        create_list(
          :parking_session, 1,
          status: [:confirmed, :created].sample,
          parking_lot: superadmin_parking_lots.first
        )
        create_list(
          :parking_session, 1,
          status: [:confirmed, :created].sample,
          parking_lot: town_manager_parking_lots.last,
        )
        create_list(
          :parking_session, 3,
          status: [:confirmed, :created].sample,
          parking_lot: parking_admin_parking_lots.first,
        )
        create_list(
          :parking_session, 2,
          status: [:confirmed, :created].sample,
          parking_lot: parking_admin_two_parking_lots.last,
        )
      end

      let(:parking_lot_ids) do
        [
          superadmin_parking_lots.first.id,
          town_manager_parking_lots.last.id,
          parking_admin_parking_lots.first.id
        ]
      end

      let(:params) do
        {
          parking_lot_ids: parking_lot_ids
        }
      end

      it "return parked vehicle" do
        expect(subject.dig(:result)).to eq I18n.t('interactions.statistics.parked_now', count: 3)
      end
    end
  end
end
