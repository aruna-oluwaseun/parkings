require 'rails_helper'

describe Reports::Detailed::OpenViolations do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:report_name) { 'Open Violations Report' }
  let(:parking_rules) { create_list(:parking_rule, 5) }
  let(:parking_sessions) { create_list(:parking_session, 5) }
  let(:parking_ticket_statuses) { Parking::CitationTicket.statuses.keys.reject { |status| status == 'unsettled' } }
  let(:open_parking_violations) { Parking::Violation.joins(:citation_ticket).where('parking_citation_tickets.status': Parking::CitationTicket.statuses['unsettled']) }
  let(:params) { {} }

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end

  before do
    create_list(:citation_ticket, 5, status: parking_ticket_statuses.sample)
    create_list(:citation_ticket, 5, status: 'unsettled')
  end

  context 'when open violations created' do
    context 'when date range not selected' do
      it 'returns list of open violations created today' do
        expect(subject[:pie_chart_total][report_name]).to eq(5)
      end
    end

    context 'when pie chart params not configured' do
      let(:parking_lot_names) { open_parking_violations.map(&:session).map(&:parking_lot).pluck(:name) }

      it 'returns all open violations for parking lots created today' do
        expect(subject[:pie_chart_total][report_name]).to eq(5)
        expect(subject[:pie_chart_data][report_name].keys).to match_array(parking_lot_names)
      end
    end

    context 'when individual parking lot params configured' do
      let(:lot) { open_parking_violations.last.session.parking_lot }
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
    let(:params) do
      {
      pie_chart: {
        range: {
          from: five_days_ago,
          to: two_days_ago
        },
      },
      individual_lots: {
        parking_lot_ids: [@parking_lot_id]
      }
    }
    end
    let(:citation_ticket) { create(:citation_ticket, status: 'unsettled') }
    let(:parking_violation) { create(:parking_violation, citation_ticket: citation_ticket, created_at: five_days_ago) }

    before do
      create(:parking_violation, citation_ticket: citation_ticket, created_at: two_days_ago)
      @parking_lot_id = parking_violation.session.parking_lot.id
      @parking_lot_name = parking_violation.session.parking_lot.name
    end

    it 'returns appropriate pie chat data' do
      expect(subject[:pie_chart_total][report_name]).to eq(1)
      expect(subject[:pie_chart_data][report_name].keys.first).to eq(@parking_lot_name)
    end
  end
end
