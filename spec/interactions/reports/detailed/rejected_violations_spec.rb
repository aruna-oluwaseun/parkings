require 'rails_helper'

describe Reports::Detailed::RejectedViolations do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:report_name) { 'Rejected Violations' }
  let(:parking_rules) { create_list(:parking_rule, 5) }
  let(:parking_sessions) { create_list(:parking_session, 5) }
  let(:parking_ticket_statuses) { Parking::Ticket.statuses.keys.reject { |status| status == 'rejected' } }
  let(:rejected_parking_violations) { Parking::Violation.joins(:ticket).where('parking_tickets.status': Parking::Ticket.statuses['rejected']) }
  let(:params) { {} }

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end

  before do
    create_list(:parking_ticket, 5, status: parking_ticket_statuses.sample)
    create_list(:parking_ticket, 5, status: 'rejected')
  end

  context 'when rejected violations created' do
    context 'when date range not selected' do
      it 'returns list of rejected violations created today' do
        expect(subject[:pie_chart_total][report_name]).to eq(5)
      end
    end

    context 'when pie chart params not configured' do
      let(:parking_lot_names) { rejected_parking_violations.map(&:session).map(&:parking_lot).pluck(:name) }

      it 'returns all rejected violations for parking lots createad today' do
        expect(subject[:pie_chart_total][report_name]).to eq(5)
        expect(subject[:pie_chart_data][report_name].keys).to match_array(parking_lot_names)
      end
    end

    context 'when individual parking lot params configured' do
      let(:lot) { rejected_parking_violations.last.session.parking_lot }
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
    let(:parking_ticket) { create(:parking_ticket, status: 'rejected') }
    let(:parking_violation) { create(:parking_violation, ticket: parking_ticket, created_at: five_days_ago) }

    before do
      # creating other Violation to be sure that filtering feature returns correct response
      create(:parking_violation, ticket: parking_ticket, created_at: two_days_ago)
      @parking_lot_id = parking_violation.session.parking_lot.id
      @parking_lot_name = parking_violation.session.parking_lot.name
    end

    it 'returns appropriate pie chat data' do
      expect(subject[:pie_chart_total][report_name]).to eq(1)
      expect(subject[:pie_chart_data][report_name].keys.first).to eq(@parking_lot_name)
    end
  end
end
