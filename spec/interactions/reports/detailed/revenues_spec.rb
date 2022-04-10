require 'rails_helper'

describe Reports::Detailed::Revenues do
  let(:admin) { create(:admin, role: super_admin_role) }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:params) { {} }

  subject do
    described_class.run(params.merge(current_user: admin)).result
  end

  before do
    @parking_lots = create_list(:parking_lot, 3)

    @parking_lots.each do |parking_lot|
      2.times do
        payment = create(:payment, parking_lot: parking_lot, amount: 2.0, status: :success)
        create(:parking_session, payments: [payment], parking_lot: parking_lot)
      end
    end
  end

  shared_examples 'returns revenues report data' do
    it 'returns report data for all existed parking lots' do
      expect(subject[:pie_chart_data].size).to eq(3)
      expect(subject[:pie_chart_data].first[:total_amount]).to eq(0.4e1)
    end
  end

  context 'when parking lots have revenues' do
    context 'when date range not selected' do
      context 'when user role is super admin' do
        it_behaves_like 'returns revenues report data'
      end

      context 'when user role is town manager' do
        let(:town_manager) { create(:admin, role: town_manager_role) }

        subject do
          described_class.run(params.merge(current_user: town_manager)).result
        end

        it_behaves_like 'returns revenues report data'
      end

      context 'when user role is parking admin' do
        let(:parking_admin) { create(:admin, role: parking_admin_role) }
        let(:parking_admin_lots_ids) { @parking_lots.pluck(:id) }

        subject do
          described_class.run(params.merge(current_user: parking_admin)).result
        end

        before do
          @parking_lots = create_list(:parking_lot, 2, admins: [parking_admin])
          parking_lot = create(:parking_lot, admins: [admin])

          @parking_lots.each do |parking_lot|
            2.times do
              payment = create(:payment, parking_lot: parking_lot, amount: 2.0, status: :success)
              create(:parking_session, payments: [payment], parking_lot: parking_lot)
            end
          end
          payment = create(:payment, parking_lot: parking_lot, amount: 2.0, status: :success)
          create(:parking_session, payments: [payment], parking_lot: parking_lot)
        end

        it 'returns pie chart data for parking lots available to user' do
          expect(subject[:pie_chart_data].pluck(:id)).to match_array parking_admin_lots_ids
          expect(subject[:pie_chart_data].size).to eq(2)
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
          parking_lot_ids: [@parking_lot.id]
        }
      }
      end

      before do
        @parking_lot = create(:parking_lot)
        @other_parking_lot = create(:parking_lot)

        payment = create(:payment, parking_lot: @parking_lot, amount: 2.0, status: :success, created_at: five_days_ago)
        create(:parking_session, payments: [payment], parking_lot: @parking_lot)

        other_payment = create(:payment, parking_lot: @other_parking_lot, amount: 2.0, status: :success)
        create(:parking_session, payments: [other_payment], parking_lot: @other_parking_lot)
      end

      it 'returns appropriate pie chat data' do
        expect(subject[:pie_chart_data].first[:id]).to eq(@parking_lot.id)
      end
    end
  end
end
