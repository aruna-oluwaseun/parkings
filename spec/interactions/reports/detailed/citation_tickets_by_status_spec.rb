require 'rails_helper'

describe Reports::Detailed::CitationTicketsByStatus do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:citation_ticket_statuses) { [:unsettled, :settled, :canceled, :sent_to_court] }
  let(:citation_tickets) { Parking::Violation.all }
  let!(:agencies) { create_list(:agency, 5) }
  let!(:parking_lots) { create_list(:parking_lot, 5) }
  let!(:report_name) { 'Open Citation Tickets' }
  let(:params) { {} }

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end

  context 'when unsettled citation tickets created' do
    context 'when date range not selected' do
      let(:params) { { citation_ticket_status: 'unsettled' } }
      before do
        create_list(:parking_violation, 2, :with_unsettled_violation_citation_ticket)
        create_list(:parking_violation, 4, :with_settled_violation_citation_ticket)
      end
      it 'returns list of open citation tickets created today' do
        expect(subject[:pie_chart_total][report_name]).to eq(2)
      end

      it 'returns response only for open citation tickets' do
        expect(subject[:title][report_name]).to eq(report_name)
      end
    end

    context 'when individual parking lot params configured' do
      let!(:lot) { create(:parking_lot) }
      let(:params) { { individual_lots: { parking_lot_ids: [lot.id] }, citation_ticket_status: 'unsettled' } }

      before do
        parking_violations =  create_list(:parking_violation, 2, :with_unsettled_violation_citation_ticket)
        parking_violations.first.session.update(parking_lot_id: lot.id)
      end

      it 'returns appropriate parking lot info base on params' do
        expect(subject[:parking_lots].last[:id]).to eq(lot.id)
      end
    end
  end

  context 'when pie chart params configured' do
    let(:today) { Time.now.utc.beginning_of_day }
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
      },
      citation_ticket_status: 'unsettled'
    }
    end
    let(:parking_violation_1) {create_list(:parking_violation, 2, :with_unsettled_violation_citation_ticket)}
    let(:report_name) { 'Open Citation Tickets' }
    let!(:lot) { create(:parking_lot) }

    before do
      # creating other Violation to be sure that filtering feature returns correct response
      parking_violations =  create_list(:parking_violation, 8, :with_unsettled_violation_citation_ticket, created_at: two_days_ago)
      parking_violations.first(3).each {|t| t.session.update(parking_lot_id: lot.id)}
      @parking_lot_id = lot.id
    end

    it 'returns appropriate pie chat data' do

      expect(subject[:pie_chart_total][report_name]).to eq(8)
      expect(subject[:pie_chart_data][report_name][lot.name]).to eq(3)
      expect(subject[:parking_lots].first[:bar_chart_data][report_name][two_days_ago]).to eq(3)
    end
  end
end
