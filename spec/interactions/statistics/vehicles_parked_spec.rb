require 'rails_helper'

describe Statistics::VehiclesParked do
  let(:t) { Time.now.beginning_of_day }
  let(:params) { {} }
  let(:current_user) { create(:admin, :superadmin) }
  let(:parking_lot) { create(:parking_lot) }
  let(:parked_yesterday) do
    create_list(
      :parking_session, 10,
      parking_lot: parking_lot,
      parked_at: t - 1.day,
      status: :finished
    )
  end

  let(:interaction) do
    described_class.run(params.merge(current_user: current_user))
  end

  let(:expected_title) { 'Vehicles Previously Parked' }
  let(:data_label) { 'Parked Before' }

  subject { interaction.result }

  context 'yesterday' do
    before do
      Rails.cache.clear
      parked_yesterday
      Rails.cache.clear
    end

    let(:expectation) do
      {
        title: expected_title,
        range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:previous],
        result: "10 #{data_label}"
      }
    end

    it { is_expected.to eq expectation }
  end
end
