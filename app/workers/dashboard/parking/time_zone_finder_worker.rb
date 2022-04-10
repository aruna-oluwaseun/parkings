module Dashboard
  module Parking
    class TimeZoneFinderWorker
      include Sidekiq::Worker
      sidekiq_options queue: :ai

      def perform(parking_lot_id)
        @parking_lot = ParkingLot.find_by(id: parking_lot_id)

        return unless @parking_lot

        @time_zone = time_zone
        @parking_lot.update(time_zone: time_zone) if time_zone_valid?
      end

      def self.update_time_zone(parking_lot)
        Sidekiq::ScheduledSet.new.each do |job|
          next if job.klass != self.name
          next if job.args.exclude?(parking_lot)
          job.delete
        end

        perform_async(parking_lot.id)
      end

      def time_zone
        ParkingLots::TimeZoneFinder.calculate(@parking_lot.location.ltd, @parking_lot.location.lng)
      end

      def time_zone_valid?
        Timezone["#{@time_zone}"].valid?
      end
    end
  end
end
