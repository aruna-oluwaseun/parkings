require 'rails_helper'

describe Reports::Detailed::CitationTickets do
  before { skip } #TODO Fix tests when Citation Ticket model will available
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:open_citation_ticket) { 'Opened Citation Tickets' }
  let(:citation_ticket_statuses) { [:unsettled, :settled, :canceled, :sent_to_court] }
  let(:citation_tickets) { Parking::Violation.all }
  let(:params) { {} }

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end

  before do
    citation_ticket_statuses.each do |citation_ticket_status|
      2.times do
        create(:citation_ticket, status: citation_ticket_status)
      end
    end
  end

  context 'when citation tickets created' do
    context 'when date range not selected' do
      it 'returns list of citation tickets created today' do
        expect(subject[:pie_chart_total][open_citation_ticket]).to eq(2)
      end
    end

    context 'when pie chart params not configured' do
      let(:parking_lot_names) do
        citation_tickets.select { |violation| violation.citation_ticket.unsettled? }.map(&:session).map(&:parking_lot).pluck(:name)
      end

      it 'returns all citation tickets for parking lots createad today' do
        expect( subject[:pie_chart_total][open_citation_ticket]).to eq(2)
        expect(subject[:pie_chart_data][open_citation_ticket].keys).to match_array(parking_lot_names)
      end
    end

    context 'when individual parking lot params configured' do
      let!(:lot) { create(:parking_lot) }
      let(:params) { { individual_lots: { parking_lot_ids: [lot.id] } } }

      before do
        parking_violation = citation_tickets.sample
        parking_violation.session.update(parking_lot_id: lot.id)
      end

      it 'returns appropriate parking lot info base on params' do
        expect(subject[:parking_lots].last[:id]).to eq(lot.id)
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
        }
      }
      end
      let(:citation_ticket) { create(:citation_ticket, status: 'unsettled') }
      let(:parking_violation) { create(:parking_violation, citation_ticket: citation_ticket, created_at: five_days_ago) }

      before do
        # creating other Violation to be sure that filtering feature returns correct response
        create(:parking_violation, citation_ticket: citation_ticket, created_at: two_days_ago)
        @parking_lot_id = parking_violation.session.parking_lot.id
        @parking_lot_name = parking_violation.session.parking_lot.name
      end

      it 'returns appropriate pie chat data' do
        expect(subject[:pie_chart_total][open_citation_ticket]).to eq(1)
        expect(subject[:pie_chart_data][open_citation_ticket].keys.last).to eq(@parking_lot_name)
      end
    end
  end
end
