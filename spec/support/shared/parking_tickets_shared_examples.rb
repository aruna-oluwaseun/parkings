shared_examples 'a parking ticket statistic' do
  let(:params) { {} }
  let(:title) { suit_samples[:title] }
  let(:data_label) { suit_samples[:label] }
  let(:status) { suit_samples[:status] }

  let(:today) { Time.now.utc.beginning_of_day }
  let(:parking_tickets_today) do
    create_list(
      :parking_ticket, 10,
      status: status,
      created_at: today
    )
  end
  let(:parking_tickets_yesterday) do
    create_list(
      :parking_ticket, 15,
      status: status,
      created_at: today-1.day
    )
  end
  let(:parking_tickets_this_week) do
    create_list(
      :parking_ticket, 70,
      status: status,
      created_at: (today.beginning_of_week.to_date...today.end_of_week.to_date).to_a.sample
    )
  end
  let(:parking_tickets_last_week) do
    create_list(
      :parking_ticket, 50,
      status: status,
      created_at: ((today - 1.week).beginning_of_week.to_date...(today - 1.week).end_of_week.to_date).to_a.sample
    )
  end
  let(:parking_tickets_this_month) do
    create_list(
      :parking_ticket, 70,
      status: status,
      created_at: (today.beginning_of_month.to_date...today.end_of_month.to_date).to_a.sample,
    )
  end
  let(:parking_tickets_last_month) do
    create_list(
      :parking_ticket, 50,
      status: status,
      created_at: ((today - 1.month).beginning_of_month.to_date...(today - 1.month).end_of_month.to_date).to_a.sample
    )
  end

  let(:todays_tickets_count) do
    parking_tickets_today.count
  end
  let(:yesterdays_tickets_count) do
    parking_tickets_yesterday.count
  end
  let(:this_weeks_tickets_count) do
    parking_tickets_this_week.count
  end
  let(:last_weeks_tickets_count) do
    parking_tickets_last_week.count
  end
  let(:this_months_tickets_count) do
    parking_tickets_this_month.count
  end
  let(:last_months_tickets_count) do
    parking_tickets_last_month.count
  end

  let(:current_user) { create(:admin, :superadmin) }
  let(:interaction) do
    described_class.run(params.merge(current_user: current_user))
  end

  subject { interaction.result }

  describe 'date filtering' do
    context 'today' do
      before do
        todays_tickets_count
        yesterdays_tickets_count
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: todays_tickets_count,
            prev_data: yesterdays_tickets_count,
            title: title,
            label: data_label,
            date_range_type: :today
          }
        end
      end
    end

    context 'week' do
      let(:params) do
        {
          range: {
            from: today.beginning_of_week.strftime('%Y-%m-%d'),
            to: today.end_of_week.strftime('%Y-%m-%d')
          }
        }
      end

      before do
        this_weeks_tickets_count
        last_weeks_tickets_count
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: this_weeks_tickets_count,
            prev_data: last_weeks_tickets_count,
            title: title,
            label: data_label,
            date_range_type: :week
          }
        end
      end
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

      before do
        this_months_tickets_count
        last_months_tickets_count
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: this_months_tickets_count,
            prev_data: last_months_tickets_count,
            title: title,
            label: data_label,
            date_range_type: :month
          }
        end
      end
    end
  end

  describe 'parking lot filtering' do
    let(:parking_lot_ids) do
      [
        parking_tickets_today.map(&:violation).map(&:session).map(&:parking_lot_id),
        parking_tickets_yesterday.map(&:violation).map(&:session).map(&:parking_lot_id)
      ].flatten.compact
    end

    before do
      todays_tickets_count
      yesterdays_tickets_count
    end

    context 'selected parking lots' do
      let(:params) do
        {
          parking_lot_ids: parking_lot_ids,
        }
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: todays_tickets_count,
            prev_data: yesterdays_tickets_count,
            title: title,
            label: data_label,
            date_range_type: :today
          }
        end
      end
    end

    context 'no parking session for selected parking lots' do
      let(:params) do
        {
          parking_lot_ids: [8338, 73_332]
        }
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: 0,
            prev_data: 0,
            title: title,
            label: data_label,
            date_range_type: :today
          }
        end
      end
    end
  end
end