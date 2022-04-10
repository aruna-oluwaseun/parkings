class UserNotifier
  class << self

    def car_entrance(user, session)
      ParkingUserMailer.car_entrance(session).deliver_later
      notification = user.notifications.create(template: :car_entrance, parking_session: session)
      send_push_notification(user, notification)
    end

    def car_left(user, session)
      ParkingUserMailer.car_left(session).deliver_later
      notification = user.notifications.create(template: :car_left, parking_session: session)
      send_push_notification(user, notification)
    end

    def car_parked(user, session)
      ParkingUserMailer.car_parked(session).deliver_later
      notification = user.notifications.create(template: :car_parked, parking_session: session)
      send_push_notification(user, notification)
    end

    def car_exit(user, session)
      ParkingUserMailer.car_exit(session).deliver_later
      notification = user.notifications.create(template: :car_exit, parking_session: session)
      send_push_notification(user, notification)
    end

    def park_expired(user, session)
      ParkingUserMailer.park_expired(session).deliver_later
      notification = user.notifications.create(template: :park_expired, parking_session: session)
      send_push_notification(user, notification)
    end

    def violation_commited(user, session, email, violation)
      ViolationMailer.commited(email, violation).deliver_later
      notification = user.notifications.create(template: :violation_commited, parking_session: session, violation: violation)
      send_push_notification(user, notification)
    end

    def park_will_expire(user, session)
      ParkingUserMailer.park_will_expire(session).deliver_later
      notification = user.notifications.create(template: :park_will_expire, parking_session: session)
      send_push_notification(user, notification)
    end

    def session_cancelled(user, session)
      ParkingUserMailer.session_cancelled(session).deliver_later
      notification = user.notifications.create(template: :session_cancelled, parking_session: session)
      send_push_notification(user, notification)
    end

    def time_extended(user, session, minutes_extended)
      ParkingUserMailer.time_extended(session).deliver_later
      notification = user.notifications.create(template: :time_extended, parking_session: session, minutes_extended:minutes_extended)
      send_push_notification(user, notification)
    end

    def wallet_filled(user, wallet_recharge_payment)
      WalletRechargePaymentMailer.wallet_filled(user, wallet_recharge_payment).deliver_later
      notification = user.notifications.create(template: :wallet_filled, wallet_recharge_payment: wallet_recharge_payment)
      send_push_notification(user, notification)
    end

    def wallet_almost_empty(user)
      WalletRechargePaymentMailer.wallet_almost_empty(user).deliver_later
      notification = user.notifications.create(template: :wallet_almost_empty)
      send_push_notification(user, notification)
    end

    def payment_successful(user, session, payment)
      PaymentMailer.payment_successful(session, payment).deliver_later
      notification = user.notifications.create(template: :payment_successful, parking_session: session, payment: payment)
      send_push_notification(user, notification)
    end

    def payment_failure(user, session)
      PaymentMailer.payment_failure(user, session).deliver_later
      notification = user.notifications.create(template: :payment_failure, parking_session: session)
      send_push_notification(user, notification)
    end

    def violation_canceled(user, session, violation)
      ViolationMailer.canceled(user, violation).deliver_later
      notification = user.notifications.create(template: :violation_canceled, parking_session: session, violation: violation)
      send_push_notification(user, notification)
    end

    def send_push_notification(user, notification)
      User::PushNotificationToken.send_notification(user, notification)
    end
  end
end
