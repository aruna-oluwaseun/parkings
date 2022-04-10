module Ai
  module Parking
    class CheckOutTimeCounterWorker
      include Sidekiq::Worker
      sidekiq_options queue: :ai

      def perform(session_id)
        @session = ParkingSession.find_by(id: session_id)
        return unless @session

        if active_session_unconfirmed? && confirmation_pending?
          @session.update(check_out: @session.check_out += 30.minutes)

          CheckOutTimeCounterWorker.increase_check_out_time(@session)
        end
      end

      def self.increase_check_out_time(session)
        Sidekiq::ScheduledSet.new.each do |job|
          next if job.klass != self.name
          next if job.args.exclude?(session)
          job.delete
        end

        perform_in(30.minutes, session.id)
      end

      def active_session_unconfirmed?
        !@session.paid? && @session.parked? && !@session.confirmed?
      end

      def confirmation_pending?
        (@session.check_out - @session.check_in) < 8.hours
      end
    end
  end
end
