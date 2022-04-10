require 'rails_helper'

describe Reports::Detailed::VoiMatches do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:report_name) { 'Voi Matches' }
  let(:parking_rules) { create_list(:parking_rule, 5) }
  let(:parking_sessions) { create_list(:parking_session, 5) }
  let(:params) { {} }
  let!(:parking_violations) do
    create_list(:parking_violation, 5, rule: parking_rules.sample, session: parking_sessions.sample)
  end

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end

  context 'when voi matches created' do
    before do
      Parking::VehicleRule.all.each_with_index do |voi_match, index|
        voi_match.update(violation: parking_violations[index])
      end

      @voi_matches = Parking::VehicleRule.all
      subject
    end

    context 'when date range not selected' do
      it 'returns list of voi matches created today' do
        expect(subject[:pie_chart_total][report_name]).to eq(5)
      end
    end

    context 'when pie chart params not configured' do
      let(:parking_lot_names) { @voi_matches.map(&:lot).pluck(:name) }

      it 'returns all voi matches for parking lots createad today' do
        expect(subject[:pie_chart_total][report_name]).to eq(5)
        expect(subject[:pie_chart_data][report_name].keys).to match_array(parking_lot_names)
      end
    end

    context 'when individual parking lot params configured' do
      let!(:lot) do
        create(:parking_vehicle_rule, violation: parking_violations.last, created_at: individual_lot_date, status: :active).lot
      end
      let(:individual_lot_date) { today }
      let(:params) { { individual_lots: { parking_lot_ids: [lot.id] } } }

      it 'returns appropriate parking lot info base on params' do
        expect(subject[:parking_lots].last[:table_data].present?).to be true
        expect(subject[:parking_lots].last[:id]).to eq(lot.id)
      end
    end
  end

  context 'when pie chart params configured' do
    let(:five_days_ago) { (today - 5.day).to_date.strftime('%Y-%m-%d') }
    let(:two_days_ago) { (today - 2.day).to_date.strftime('%Y-%m-%d') }
    let(:params) { { pie_chart: { range: { from: five_days_ago, to: two_days_ago }, parking_lot_ids: [@parking_lot_id] } } }

    before do
      [five_days_ago, two_days_ago].each_with_object([]) do |date, result|
        result << create(:parking_vehicle_rule, created_at: date, status: :active)
      end

      voi_match = Parking::VehicleRule.last

      @parking_lot_id = voi_match.lot.id
      @parking_lot_name = voi_match.lot.name
      subject
    end

    it 'returns appropriate pie chat data' do
      expect(subject[:pie_chart_total][report_name]).to eq(1)
      expect(subject[:pie_chart_data][report_name].keys.first).to eq(@parking_lot_name)
    end
  end
end
