require 'rails_helper'

describe Reports::Detailed::VehiclesCurrentlyParked do

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end
  let!(:admin) { create(:admin, role: super_admin_role) }
  let!(:report_name) { 'Vehicles Currently Parked' }
  let!(:params) { {} }

  context 'all parking lot params configured' do
    let(:parking_lots) { create_list(:parking_lot, 5) }
    let(:today) { Time.now.utc.beginning_of_day.strftime('%Y-%m-%d') }
    let(:end_of_today) { Time.now.utc.end_of_day.strftime('%Y-%m-%d') }
    let(:five_days_ago) { 5.day.ago}
    let(:params) do
    {
      pie_chart: {
        range: {
          from: today,
          to: end_of_today
        },
      },
    }
    end
    let(:expectation) do
    {
      "#{parking_lots.first.name}" => 3,
      "#{parking_lots.second.name}" => 4,
    }
    end

    before do
      create_list(
        :parking_session, 3,
        status: [:confirmed, :created].sample,
        parking_lot: parking_lots.first
      )
      create_list(
        :parking_session, 4,
        status: [:confirmed, :created].sample,
        parking_lot: parking_lots.second
      )
      create_list(
        :parking_session, 4,
        status: [:confirmed, :created].sample,
        created_at: five_days_ago,
        parking_lot: parking_lots.second
      )
    end

    it 'returns appropriate pie chart data' do
      expect(subject[:pie_chart_total][report_name]).to eq(7)
      expect(subject[:pie_chart_data][report_name]).to eq(expectation)
    end
  end

  context 'individual parking lot params configured' do
    let(:parking_lots) { create_list(:parking_lot, 5) }
    let(:today) { Time.now.utc.beginning_of_day.strftime('%Y-%m-%d') }
    let(:end_of_today) { Time.now.utc.end_of_day.strftime('%Y-%m-%d') }
    let(:five_days_ago) { 5.day.ago}
    let(:params) do
    {
      pie_chart: {
        range: {
          from: today,
          to: end_of_today
        },
        parking_lot_ids: [parking_lots.first.id]
      },

    }
    end
    let(:expectation) do
    {
      "#{parking_lots.first.name}" => 5,
    }
    end
    before do
      create_list(
        :parking_session, 5,
        status: [:confirmed, :created].sample,
        parking_lot: parking_lots.first
      )
      create_list(
        :parking_session, 4,
        status: [:confirmed, :created].sample,
        parking_lot: parking_lots.second
      )
      create_list(
        :parking_session, 4,
        status: [:confirmed, :created].sample,
        created_at: five_days_ago,
        parking_lot: parking_lots.first
      )
    end

    it 'returns appropriate pie chart data for this parking lot id' do
      expect(subject[:pie_chart_total][report_name]).to eq(5)
      expect(subject[:pie_chart_data][report_name]).to eq(expectation)
    end
  end
end

