require 'rails_helper'

describe Reports::Detailed::Violations do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:open_violation) { 'Opened violations' }
  let!(:parking_violations) { Parking::Violation.all }
  let(:params) { {} }

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end

  before do
    create_list(:parking_ticket, 5)
    Parking::Ticket.statuses.values
  end

  context 'when parking violations created' do
    context 'when date range not selected' do
      it 'returns list of violations created today' do
        expect(subject[:pie_chart_total][open_violation]).to eq(5)
      end
    end

    context 'when pie chart params not configured' do
      let(:parking_lot_names) do
        parking_violations.select { |violation| violation.ticket.opened? }.map(&:session).map(&:parking_lot).pluck(:name)
      end

      it 'returns all violations for parking lots createad today' do
        expect(subject[:pie_chart_total][open_violation]).to eq(5)
        expect(subject[:pie_chart_data][open_violation].keys).to match_array(parking_lot_names)
      end
    end
  end

  context 'when individual parking lot params configured' do
    let!(:lot) { create(:parking_lot) }
    let(:params) { { individual_lots: { parking_lot_ids: [lot.id] } } }

    before do
      parking_violation = parking_violations.sample
      parking_violation.session.update(parking_lot_id: lot.id)
    end

    it 'returns appropriate parking lot info base on params' do
      expect(subject[:parking_lots].last[:id]).to eq(lot.id)
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
    let(:parking_ticket) { create(:parking_ticket) }
    let(:parking_violation) { create(:parking_violation, ticket: parking_ticket, created_at: five_days_ago) }

    before do
      # creating other Violation to be sure that filtering feature returns correct response
      create(:parking_violation, ticket: parking_ticket, created_at: two_days_ago)
      @parking_lot_id = parking_violation.session.parking_lot.id
      @parking_lot_name = parking_violation.session.parking_lot.name
    end

    it 'returns appropriate pie chat data' do
      expect(subject[:pie_chart_total][open_violation]).to eq(1)
      expect(subject[:pie_chart_data][open_violation].keys.last).to eq(@parking_lot_name)
    end
  end
end
