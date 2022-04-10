module ParkingSessions
  class Extend < ::ApplicationInteraction

    integer :check_out, default: 30.minutes.from_now.to_i
    object :object, class: ParkingSession

    validate do
      if check_out < object.check_in.to_i
        errors.add(:check_out, :less_than_check_in)
        throw(:abort)
      end
      if object.check_out
        if object.check_out.to_i > check_out
          errors.add(:check_out, :less_than_previous_value)
          throw(:abort)
        end
      end
    end

    def execute
      @current_checkout_time = object.current_checkout_time
      object.update(check_out: Time.at(check_out))
      errors.merge!(object.errors) if object.errors.any?
      if valid? && user = object.vehicle.user
        UserNotifier.time_extended(user, object, minutes_extended)
      end
      Ai::Parking::OvertimeTickerWorker.extend_or_create(object)
    end

    private

    def minutes_extended
      (object.check_out - @current_checkout_time).to_i / 60
    end
  end
end
