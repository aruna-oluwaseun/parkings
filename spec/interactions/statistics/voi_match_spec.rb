require 'rails_helper'
include ActionView::Helpers::NumberHelper

describe Statistics::VoiMatch do
  let(:today) { Time.now.utc.beginning_of_day }
  let(:voi_today) do
    create_list(
      :parking_vehicle_rule, 10,
      created_at: today,
      status: :active
    )
  end
  let(:voi_yesterday) do
    create_list(
      :parking_vehicle_rule, 15,
      created_at: today-1.day,
      status: :active
    )
  end
  let(:voi_this_week) do
    create_list(
      :parking_vehicle_rule, 70,
      created_at: (today.beginning_of_week.to_date...today.end_of_week.to_date).to_a.sample,
      status: :active
    )
  end
  let(:voi_last_week) do
    create_list(
      :parking_vehicle_rule, 50,
      created_at: ((today - 1.week).beginning_of_week.to_date...(today - 1.week).end_of_week.to_date).to_a.sample,
      status: :active
    )
  end
  let(:voi_this_month) do
    create_list(
      :parking_vehicle_rule, 70,
      created_at: (today.beginning_of_month.to_date...today.end_of_month.to_date).to_a.sample,
      status: :active
    )
  end
  let(:voi_last_month) do
    create_list(
      :parking_vehicle_rule, 50,
      created_at: ((today - 1.month).beginning_of_month.to_date...(today - 1.month).end_of_month.to_date).to_a.sample,
      status: :active
    )
  end

  let(:todays_voi)      { voi_today.count }
  let(:yesterdays_voi)  { voi_yesterday.count }
  let(:this_weeks_voi)  { voi_this_week.count }
  let(:last_weeks_voi)  { voi_last_week.count }
  let(:this_months_voi) { voi_this_month.count }
  let(:last_months_voi) { voi_last_month.count }

  let(:current_user) { create(:admin, :superadmin) }
  let(:interaction) do
    Rails.cache.clear
    described_class.run(params.merge(current_user: current_user))
  end

  subject { interaction.result }

  describe 'date filtering' do
    context 'today' do
      let(:params) do
        {
          range: {
            from: today.strftime('%Y-%m-%d')
          }
        }
      end
      let(:percentage) do
        (((todays_voi-yesterdays_voi)*100)/yesterdays_voi.to_f)
      end
      let(:expectation) do
        {
          title: 'Vehicle of Interest Match',
          range_current_period: 'Today',
          result: "#{todays_voi} VOI Matched",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{number_with_delimiter(yesterdays_voi)} from Yesterday"
        }
      end

      before do
        todays_voi
        yesterdays_voi
      end

      it { is_expected.to eq expectation }
    end

    context 'week' do
      let(:params) do
        {
          range: {
            from: today.beginning_of_week.strftime('%Y-%m-%d'),
            to: today.end_of_week.strftime('%Y-%m-%d')
          }
        }
      end
      let(:percentage) do
        (((this_weeks_voi-last_weeks_voi)*100)/last_weeks_voi.to_f)
      end
      let(:expectation) do
        {
          title: 'Vehicle of Interest Match',
          range_current_period: 'This week',
          result: "#{this_weeks_voi} VOI Matched",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{number_with_delimiter(last_weeks_voi)} from Last week"
        }
      end

      before do
        this_weeks_voi
        last_weeks_voi
      end

      it { is_expected.to eq expectation }
    end

    context 'month' do
      let(:params) do
        {
          range: {
            from: today.beginning_of_month.strftime('%Y-%m-%d'),
            to: today.end_of_month.strftime('%Y-%m-%d')
          }
        }
      end
      let(:percentage) do
        (((this_months_voi.to_f-last_months_voi.to_f)*100)/last_months_voi.to_f)
      end
      let(:expectation) do
        {
          title: 'Vehicle of Interest Match',
          range_current_period: 'This month',
          result: "#{this_months_voi} VOI Matched",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{number_with_delimiter(last_months_voi)} from Last month"
        }
      end

      before do
        this_months_voi
        last_months_voi
      end

      it { is_expected.to eq expectation }
    end
  end

  describe 'parking lot filtering' do
    let(:parking_lot_ids) do
      [
        voi_today.map(&:lot),
        voi_yesterday.map(&:lot)
      ].flatten.uniq
    end

    before do
      todays_voi
      yesterdays_voi
    end

    context 'selected parking lots' do
      let(:params) do
        {
          range: {
            from: today.strftime('%Y-%m-%d'),
            parking_lot_ids: parking_lot_ids
          }
        }
      end
      let(:percentage) do
        (((todays_voi-yesterdays_voi)*100)/yesterdays_voi.to_f)
      end
      let(:expectation) do
        {
          title: 'Vehicle of Interest Match',
          range_current_period: 'Today',
          result: "#{todays_voi} VOI Matched",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{number_with_delimiter(yesterdays_voi)} from Yesterday"
        }
      end

      before do
        todays_voi
        yesterdays_voi
      end

      it { is_expected.to eq expectation }
    end

    context 'no parking session parking lots' do
      let(:params) do
        {
          range: {
            from: today.strftime('%Y-%m-%d')
          },
          parking_lot_ids: [8_338, 73_332]
        }
      end

      let(:expectation) do
        {
          title: 'Vehicle of Interest Match',
          range_current_period: 'Today',
          result: "0 VOI Matched",
          compare_with_previous_period: {
            raise: false,
            percentage: "0.00%"
          },
          result_previous_period: 'NO DATA from Yesterday'
        }
      end

      it { is_expected.to eq expectation }
    end
  end
end
