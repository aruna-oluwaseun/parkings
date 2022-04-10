require 'rails_helper'
RSpec.describe Ai::Parking::CheckOutTimeCounterWorker, type: :worker do
  let(:payment) { create(:payment, status: 'success', amount: 100_000) }
  let(:session) { create(:parking_session, ai_status: 'parked') }

  describe '#perform' do
    before do
      allow(described_class).to receive(:increase_check_out_time)
    end

    context 'when parking session active and confirmed' do

      shared_examples "doesn't change check out time" do
        it "doesn't increase check out time on 30 minutes" do
          expect(session.check_out.utc.to_s).to eq(checkout_time.utc.to_s)
        end
      end

      context 'when parking session paid' do
        let!(:checkout_time) { session.check_out }

        before do
          session.payments << payment
          described_class.perform_async(session.id)
          session.reload
        end

        it_behaves_like "doesn't change check out time"
      end

      context 'when parking session confirmed' do
        let!(:checkout_time) { session.check_out }

        before do
          session.confirmed!
          described_class.perform_async(session.id)
          session.reload
        end

        it_behaves_like "doesn't change check out time"
      end

      context 'when time out time is over' do
        let!(:checkout_time) { session.check_out }

        before do
          session.update(check_in: session.check_out - 10.hours)
          described_class.perform_async(session.id)
          session.reload
        end

        it_behaves_like "doesn't change check out time"
      end
    end

    context 'when parkign session active' do
      context 'when parking session unpaid and unconfrimed' do
        let!(:checkout_time) { session.check_out }

        before do
          described_class.perform_async(session.id)
          session.reload
        end

        it 'increases check out time on 30 minutes' do
          expect(session.check_out.utc.to_s).to eq((checkout_time + 30.minutes).utc.to_s)
        end
      end
    end

    context 'when job fail' do
      it 'retries failed jobs' do
        expect(described_class.sidekiq_options_hash['retry']).to be_truthy
      end
    end
  end
end
