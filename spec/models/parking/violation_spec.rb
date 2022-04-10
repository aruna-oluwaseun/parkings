require 'rails_helper'

RSpec.describe Parking::Violation, type: :model do
  describe 'creating parking violation' do
    it 'has valid factory' do
      violation = create(:parking_violation)
      expect(violation).to be_valid
      expect(violation.rule).to be_present
      expect(violation.session).to be_present
      expect(violation.description).to be_present
    end

    context 'with unsassigned admin ticket' do
      it 'has valid factory' do
        violation = create(
          :parking_violation,
          :with_violation_ticket_unassigned_admin
        )
      end
    end
  end

  describe 'scope' do
    context 'opened' do
      let(:count) { 3 }
      let!(:violations) do
        create_list(
          :parking_violation, count, :with_opened_violation_ticket
        )
      end

      subject do
        described_class.opened.count
      end

      it { is_expected.to eq count }
    end
  end

  describe '#delegation' do
    let(:parking_violation) { create(:parking_violation) }
    context 'parking_lot' do
      after { parking_violation.parking_lot }
      it "delegates to session" do
        expect(parking_violation.session).to receive(:parking_lot)
      end
    end

    context 'officers' do
      after { parking_violation.officers }
      it "delegates to agency" do
        expect(parking_violation.agency).to receive(:officers)
      end
    end

    context 'vehicle' do
      after { parking_violation.vehicle }
      it "delegates to session" do
        expect(parking_violation.session).to receive(:vehicle)
      end
    end

    context 'agency' do
      after { parking_violation.agency }
      it "delegates to rule" do
        expect(parking_violation.rule).to receive(:agency)
      end
    end
  end
end
