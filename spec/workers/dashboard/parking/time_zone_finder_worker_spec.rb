require 'rails_helper'

RSpec.describe Dashboard::Parking::TimeZoneFinderWorker, type: :worker do
  let(:parking_lot) { create(:parking_lot) }

  describe '#peform' do
    context 'when time zone valid' do
      before do
        allow_any_instance_of(described_class).to receive(:time_zone).and_return("Europe/Minsk")
        parking_lot.location.update(ltd: 53.904541, lng: 27.5615238)
        described_class.perform_async(parking_lot.id)
        parking_lot.reload
      end

      it 'updates time zone' do
        expect(parking_lot.time_zone).to eq("Europe/Minsk")
      end
    end

    context 'when time zone invalid' do
      let(:default_time_zone) { 'Eastern Time (US & Canada)' }

      before do
        allow_any_instance_of(described_class).to receive(:time_zone).and_return("invalid")
        parking_lot.location.update(ltd: 'invalid_ltd', lng: 'invalid_lng')
        described_class.perform_async(parking_lot.id)
        parking_lot.reload
      end

      it 'leaves default time zone' do
        expect(parking_lot.time_zone).to eq(default_time_zone)
      end
    end
  end
end
