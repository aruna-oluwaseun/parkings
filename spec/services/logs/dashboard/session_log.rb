module Logs
  module Dashboard
    class SessionLog < ::Logs::Base

      def execute
        log = PaperTrail::Version.where(item_type: 'ParkingSession')
        log.all.map { |log| { comment: log.comment, object: log.object, created_at: log.created_at } }
      end

      def comment
        :comment
      end

      def object
        :object
      end

      def created_at
        :created_at
     end

    end
  end
end
