require 'rails_helper'
include ActionView::Helpers::NumberHelper

describe Statistics::CitationTicketsOpened do
  subject { interaction.result }
  let(:interaction) do
    described_class.run(params.merge(current_user: current_user))
  end
  let!(:current_user) { create(:admin, :superadmin) }
  let(:title) { '[Open] Citation Tickets' }
  let(:data_label) { 'Open' }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:params) { {} }
  let!(:agencies) { create_list(:agency, 5) }
  let!(:parking_lots) { create_list(:parking_lot, 5) }

  context 'All today parking lots' do
    let!(:citation_tickets_open_today) {create_list(:citation_ticket, 3, status: :unsettled)}

    let(:expectation) do
      {
        title: title,
        range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
        result: "#{citation_tickets_open_today.count} #{data_label}"
      }
    end

    let(:interaction) do
      described_class.run(params.merge(current_user: current_user))
    end

    before do
      citation_tickets_open_today
    end

    it { is_expected.to eq expectation }
  end


  context 'Selected parking lots' do
    let!(:parking_violation) { create_list(:parking_violation, 2, :with_unsettled_violation_citation_ticket)}

    let(:params) do
      {
        parking_lot_ids: parking_lot_ids
      }
    end

    context '1st parking lot' do
      let(:parking_lot_ids) { [parking_violation.second.parking_lot.id] }
      it "returns opened citation ticket count" do
        expect(subject.dig(:result)).to eq '1 Open'
      end
    end

    context 'adding citation ticket' do
      let(:parking_lot_ids) { [parking_violation.second.parking_lot.id] }
      before do
        create(:citation_ticket, status: :unsettled, violation: parking_violation.second)
      end
      it "returns updated citation ticket count" do
        expect(subject.dig(:result)).to eq '2 Open'
      end
    end

    context 'all parking lot' do
      let(:parking_lot_ids) { [parking_violation.first.parking_lot.id, parking_violation.second.parking_lot.id] }
      it "return all open citation tickets" do
        expect(subject.dig(:result)).to eq '2 Open'
      end
    end
  end

  context 'filter by date' do
    context 'week' do
      let(:params) do
        {
          range: {
            from: today.beginning_of_week.strftime('%Y-%m-%d'),
            to: today.end_of_week.strftime('%Y-%m-%d')
          }
        }
      end
      let(:citation_tickets_this_week) do
        create_list(
          :citation_ticket, 3,
          created_at: (today.beginning_of_week.to_date...today.end_of_week.to_date).to_a.sample,
          status: :unsettled
        )
      end
      let(:citation_tickets_last_week) do
        create_list(
          :citation_ticket, 4,
          created_at: ((today - 1.week).beginning_of_week.to_date...(today - 1.week).end_of_week.to_date).to_a.sample,
          status: :unsettled
        )
      end
      let(:citation_tickets_this_week_count)  { citation_tickets_this_week.count }
      let(:citation_tickets_last_week_count)  { citation_tickets_last_week.count }

      let(:expectation) do
        {
          title: title,
          range_current_period: 'This week',
          result: "#{citation_tickets_this_week_count} Open"
        }
      end
      before do
        citation_tickets_this_week_count
        citation_tickets_last_week_count
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

      let(:citation_tickets_this_month) do
        create_list(
          :citation_ticket, 3,
          created_at: (today.beginning_of_month.to_date...today.end_of_month.to_date).to_a.sample,
          status: :unsettled
        )
      end
      let(:citation_tickets_last_month) do
        create_list(
          :citation_ticket, 4,
          created_at: ((today - 1.week).beginning_of_month.to_date...(today - 1.week).end_of_month.to_date).to_a.sample,
          status: :unsettled
        )
      end
      let(:citation_tickets_last_month_count)  { citation_tickets_last_month.count }
      let(:citation_tickets_this_month_count)  { citation_tickets_this_month.count }

      let(:expectation) do
        {
          title: title,
          range_current_period: 'This month',
          result: "#{citation_tickets_this_month_count} Open"
        }
      end
      before do
        citation_tickets_this_month_count
      end

      it { is_expected.to eq expectation }
    end
  end
end
