require 'rails_helper'

describe Statistics::ViolationReportsOpened do
  subject { interaction.result }
  let(:interaction) do
    described_class.run(params.merge(current_user: current_user))
  end

  let(:params) { {} }
  let(:title) { '[Open] Violation Reports' }
  let(:data_label) { 'Open' }
  let(:today) { Time.now.utc.beginning_of_day }
  let(:current_user) { create(:admin, :superadmin) }
  let!(:parking_lots) { create_list(:parking_lot, 5) }

  let!(:parking_violations) do
    create_list(
      :parking_violation, 10,
      :with_opened_violation_ticket_and_session
    )
  end
  context 'All parking lots' do

    before do
      parking_violations
    end

    let(:expectation) do
      {
        title: title,
        range_current_period: Statistics::Base::DATE_RANGE_LABELS[:today][:current],
        result: "#{parking_violations.count} #{data_label}",
        :compare_with_previous_period => {:percentage=>"1,000.00%", :raise=>true},
        :result_previous_period => "NO DATA from Yesterday",
      }
    end

    it { is_expected.to eq expectation }
  end

  context 'Selected parking lots' do
    let(:params) do
      {
        parking_lot_ids: [parking_lots.first.id]
      }
    end

    before do
      Parking::Violation.first(3).each do |violation|
        session = violation.session
        session.parking_lot = parking_lots.first
        session.save!
      end
    end

    it "return open violation" do
      expect(subject.dig(:result)).to eq '3 Open'
    end
  end
end