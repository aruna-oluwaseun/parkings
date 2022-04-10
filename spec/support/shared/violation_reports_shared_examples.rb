shared_examples 'a violation reports' do
  let(:params) { {} }
  let(:title)  { suit_samples[:title] }
  let(:data_label)  { suit_samples[:label] }
  let(:status) { suit_samples[:status] }
  let(:trait)  { "with_#{suit_samples[:status]}_violation_ticket".to_sym }

  let(:today) { Time.now.utc.beginning_of_day }

  let(:violations_today) do
    create_list(
      :parking_violation, 3, trait,
      :with_parking_session, created_at: today
    )
  end
  let(:violations_yesterday) do
    create_list(
      :parking_violation, 6, trait,
      :with_parking_session, created_at: today-1.day
    )
  end
  let(:violations_this_week) do
    create_list(
      :parking_violation, 9, trait,
      :with_parking_session, created_at: (today.beginning_of_week.to_date...today.end_of_week.to_date).to_a.sample
    )
  end
  let(:violations_last_week) do
    create_list(
      :parking_violation, 18, trait,
      :with_parking_session, created_at: ((today - 1.week).beginning_of_week.to_date...(today - 1.week).end_of_week.to_date).to_a.sample
    )
  end
  let(:violations_this_month) do
    create_list(
      :parking_violation, 21, trait,
      :with_parking_session, created_at: (today.beginning_of_month.to_date...today.end_of_month.to_date).to_a.sample
    )
  end
  let(:violations_last_month) do
    create_list(
      :parking_violation, 15, trait,
      :with_parking_session, created_at: ((today - 1.month).beginning_of_month.to_date...(today - 1.month).end_of_month.to_date).to_a.sample
    )
  end

  let(:todays_violations) do
    violations_today.count
  end
  let(:yesterdays_violations) do
    violations_yesterday.count
  end
  let(:this_weeks_violations) do
    violations_this_week.count
  end
  let(:last_weeks_violations) do
    violations_last_week.count
  end
  let(:this_months_violations) do
    violations_this_month.count
  end
  let(:last_months_violations) do
    violations_last_month.count
  end

  let(:current_user) { create(:admin, :superadmin) }
  let(:interaction) do
    described_class.run(params.merge(current_user: current_user))
  end

  subject { interaction.result }

  describe 'date filtering' do
    context 'today' do
      before do
        todays_violations
        yesterdays_violations
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: todays_violations,
            prev_data: yesterdays_violations,
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
        this_weeks_violations
        last_weeks_violations
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: this_weeks_violations,
            prev_data: last_weeks_violations,
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
        this_months_violations
        last_months_violations
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: this_months_violations,
            prev_data: last_months_violations,
            title: title,
            label: data_label,
            date_range_type: :month
          }
        end
      end
    end
  end

  describe 'parking lot filtering' do
    let!(:violations_today) do
      create_list(
        :parking_violation, 3, trait,
        :with_parking_session, created_at: today
      )
    end
    let!(:violations_yesterday) do
      create_list(
        :parking_violation, 6, trait,
        :with_parking_session, created_at: today-1.day
      )
    end

    context 'selected parking lots' do
      let(:params) do
        {
          parking_lot_ids: Parking::Violation.send(status).map(&:session).map(&:parking_lot_id)
        }
      end

      it_behaves_like 'a count statistic' do
        let(:samples) do
          {
            current_data: violations_today.count,
            prev_data: violations_yesterday.count,
            title: title,
            label: data_label,
            date_range_type: :today
          }
        end
      end
    end

    context 'no parking session parking lots' do
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