require 'rails_helper'
include ActionView::Helpers::NumberHelper

describe Statistics::Revenue do
  let(:t) { Time.now.utc.beginning_of_day }
  let(:params) { {} }
  let(:payment_today) do
    create_list(
      :payment, 10, :with_parking_session,
      amount: 1, created_at: t,
      status: :success
    )
  end
  let(:payment_yesterday) do
    create_list(
      :payment, 15, :with_parking_session,
      amount: 1, created_at: t-1.day,
      status: :success
    )
  end
  let(:payment_this_week) do
    create_list(
      :payment, 70, :with_parking_session, amount: 1,
      created_at: (t.beginning_of_week.to_date...t.end_of_week.to_date).to_a.sample,
      status: :success
    )
  end
  let(:payment_last_week) do
    create_list(
      :payment, 50, :with_parking_session, amount: 1,
      created_at: ((t - 1.week).beginning_of_week.to_date...(t - 1.week).end_of_week.to_date).to_a.sample,
      status: :success
    )
  end
  let(:payment_this_month) do
    create_list(
      :payment, 70, :with_parking_session, amount: 1,
      created_at: (t.beginning_of_month.to_date...t.end_of_month.to_date).to_a.sample,
      status: :success
    )
  end
  let(:payment_last_month) do
    create_list(
      :payment, 50, :with_parking_session, amount: 1,
      created_at: ((t - 1.month).beginning_of_month.to_date...(t - 1.month).end_of_month.to_date).to_a.sample,
      status: :success
    )
  end

  let(:todays_revenue) do
    payment_today.sum(&:amount_to_dollar)
  end
  let(:yesterdays_revenue) do
    payment_yesterday.sum(&:amount_to_dollar)
  end
  let(:this_weeks_revenue) do
    payment_this_week.sum(&:amount_to_dollar)
  end
  let(:last_weeks_revenue) do
    payment_last_week.sum(&:amount_to_dollar)
  end
  let(:this_months_revenue) do
    payment_this_month.sum(&:amount_to_dollar)
  end
  let(:last_months_revenue) do
    payment_last_month.sum(&:amount_to_dollar)
  end

  let(:current_user) { create(:admin, :superadmin) }
  let(:interaction) do
    described_class.run(params.merge(current_user: current_user))
  end

  subject { interaction.result }

  describe 'date filtering' do
    context 'today' do
      let(:percentage) do
        (((todays_revenue.to_f-yesterdays_revenue.to_f)*100)/yesterdays_revenue.to_f)
      end
      let(:expectation) do
        {
          title: 'Revenue Earned',
          range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
          result: "#{todays_revenue.format} Parking Fees",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{yesterdays_revenue.format} from #{Statistics::Base::DATE_RANGE_LABELS[:today][:previous]}"
        }
      end

      before do
        todays_revenue
        yesterdays_revenue
      end

      it { is_expected.to eq expectation }
    end

    context 'week' do
      let(:params) do
        {
          range: {
            from: t.beginning_of_week.strftime('%Y-%m-%d'),
            to: t.end_of_week.strftime('%Y-%m-%d')
          }
        }
      end
      let(:percentage) do
        (((this_weeks_revenue.to_f-last_weeks_revenue.to_f)*100)/last_weeks_revenue.to_f)
      end
      let(:expectation) do
        {
          title: 'Revenue Earned',
          range_current_period: Statistics::Base::DATE_RANGE_LABELS[:week][:current],
          result: "#{this_weeks_revenue.format} Parking Fees",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{last_weeks_revenue.format} from #{Statistics::Base::DATE_RANGE_LABELS[:week][:previous]}"
        }
      end

      before do
        this_weeks_revenue
        last_weeks_revenue
      end

      it { is_expected.to eq expectation }
    end

    context 'month' do
      let(:params) do
        {
          range: {
            from: t.beginning_of_month.strftime('%Y-%m-%d'),
            to: t.end_of_month.strftime('%Y-%m-%d')
          }
        }
      end
      let(:percentage) do
        (((this_months_revenue.to_f-last_months_revenue.to_f)*100)/last_months_revenue.to_f)
      end
      let(:expectation) do
        {
          title: 'Revenue Earned',
          range_current_period: Statistics::Base::DATE_RANGE_LABELS[:month][:current],
          result: "#{this_months_revenue.format} Parking Fees",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{last_months_revenue.format} from #{Statistics::Base::DATE_RANGE_LABELS[:month][:previous]}"
        }
      end

      before do
        this_months_revenue
        last_months_revenue
      end

      it { is_expected.to eq expectation }
    end
  end

  describe 'parking lot filtering' do
    let(:parking_lot_ids) do
      [
        payment_today.map(&:parking_session).map(&:parking_lot_id),
        payment_yesterday.map(&:parking_session).map(&:parking_lot_id)
      ].flatten.uniq
    end

    before do
      todays_revenue
      yesterdays_revenue
    end

    context 'selected parking lots' do
      let(:params) do
        {
          range: {
            from: t.strftime('%Y-%m-%d'),
            parking_lot_ids: parking_lot_ids
          }
        }
      end
      let(:percentage) do
        (((todays_revenue.to_f-yesterdays_revenue.to_f)*100)/yesterdays_revenue.to_f)
      end
      let(:expectation) do
        {
          title: 'Revenue Earned',
          range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
          result: "#{todays_revenue.format} Parking Fees",
          compare_with_previous_period: {
            raise: percentage > 0,
            percentage: "#{sprintf "%.2f", percentage.abs}%"
          },
          result_previous_period: "#{yesterdays_revenue.format} from #{Statistics::Base::DATE_RANGE_LABELS[:today][:previous]}"
        }
      end

      it { is_expected.to eq expectation }
    end

    context 'no parking session parking lots' do
      let(:params) do
        {
          range: {
            from: t.strftime('%Y-%m-%d')
          },
          parking_lot_ids: [8338, 73_332]
        }
      end

      let(:expectation) do
        {
          title: 'Revenue Earned',
          range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
          result: "NO DATA",
          compare_with_previous_period: {
            raise: false,
            percentage: "0.00%"
          },
          result_previous_period: "NO DATA from #{Statistics::Base::DATE_RANGE_LABELS[:today][:previous]}"
        }
      end

      it { is_expected.to eq expectation }
    end
  end
end