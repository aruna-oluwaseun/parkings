require 'rails_helper'

class DummyClass < Statistics::Base
  def date_ranges
    {
      from: @from,
      to: @to,
      previous_from: @previous_from,
      previous_to: @previous_to
    }
  end
end

describe DummyClass do
  describe '#set_date_variables' do
    let(:t) { Time.now.utc.beginning_of_day }
    let(:params) { {} }
    let(:interaction) { described_class.run(params) }

    subject do
      interaction.date_ranges
    end

    before do
      allow(interaction).to receive(:current_time_zone).and_return('UTC')
      interaction.set_date_variables
    end

    describe 'default date range (today)' do
      let(:expectation) do
        {
          from: t.beginning_of_day,
          to: t.end_of_day,
          previous_from: (t.beginning_of_day - 1.day),
          previous_to: (t.end_of_day - 1.day)
        }
      end

      it { is_expected.to eq expectation }
    end

    describe 'week' do
      let(:params) do
        {
          range: {
            from: t.beginning_of_week.strftime('%Y-%m-%d'),
            to: t.end_of_week.strftime('%Y-%m-%d')
          }
        }
      end
      let(:expectation) do
        {
          from: t.beginning_of_week,
          to: t.end_of_week,
          previous_from: t.beginning_of_week - 1.week,
          previous_to: t.end_of_week - 1.week
        }
      end

      it { is_expected.to eq expectation }
    end

    describe 'month' do
      let(:params) do
        {
          range: {
            from: t.beginning_of_month.strftime('%Y-%m-%d'),
            to: t.end_of_month.strftime('%Y-%m-%d')
          }
        }
      end
      let(:expectation) do
        {
          from: t.beginning_of_month,
          to: t.end_of_month,
          previous_from: (t.beginning_of_month - 1.month).beginning_of_month,
          previous_to: (t.end_of_month - 1.month).end_of_month
        }
      end

      it { is_expected.to eq expectation }
    end

    describe 'custom' do
      let(:params) do
        {
          range: {
            from: '2020-05-10',
            to: '2020-05-20'
          }
        }
      end
      let(:expectation) do
        {
          from: Time.zone.parse('2020-05-10').utc.beginning_of_day,
          to: Time.zone.parse('2020-05-20').utc.end_of_day,
          previous_from: Time.zone.parse('2020-04-30').utc.beginning_of_day,
          previous_to: Time.zone.parse('2020-05-10').utc.end_of_day
        }
      end

      it { is_expected.to eq expectation }
    end
  end
end