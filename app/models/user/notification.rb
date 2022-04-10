class User::Notification < ApplicationRecord
  belongs_to :user
  belongs_to :parking_session, optional: true
  belongs_to :payment, optional: true
  belongs_to :wallet_recharge_payment, optional: true
  belongs_to :violation, class_name: 'Parking::Violation', foreign_key: 'violation_id',  optional: true

  enum status: { unread: 0, read: 1 }
  enum template: {
    car_entrance: 0, # Vehicle entered a parking lot
    car_parked: 1, # Vehicle successfully parked in parking space
    car_exit: 2, # Vehicle successfully exited the parking lot
    car_left: 3,  # Vehicle successfully exited from a parking space
    park_will_to_expire: 4, # Parking time about to expire
    park_expired: 5, # Parking time expired
    wallet_filled: 6, # Wallet filled successfully
    payment_successful: 7, # Payment successful
    payment_failure: 8, # Payment failed
    violation_commited: 9, # Violation committed
    session_cancelled: 10, # Session was cancelled by the user (left parking space)
    park_started: 11, # Parking time started
    park_will_expire: 12, # Parking time is about to expire
    payment_reminder: 13, # Payment reminder for extending parking time
    violation_received: 14, # Violation ticket received
    violation_resolved: 15,  # Violation ticket resolved,
    car_switched: 16, # Car switched parking space
    vehicle_of_interest: 17, # Vehicle of Interest enters the parking lot
    vehicle_becomes_interest: 18, # Car becomes a vehicle of interest
    time_extended: 19, # When user extended time
    wallet_almost_empty: 20, # When the subscriber wallet hits the 1$ minimum limit
    violation_canceled: 21, # when the officer cancel a violation committed by a subscriber(user)
    violation_assigned: 22 # when an authorize user assigns a violation to you (logged in officer) PSAD-1729
  } # https://telsoft.atlassian.net/browse/PSAD-227

  before_validation do
    if !title && template
      title_locale = "activerecord.models.user/notification.templates.#{template}_title"
      text_locale = "activerecord.models.user/notification.templates.#{template}_text"
      self.title = I18n.t(title_locale) if I18n.exists?(title_locale)
      self.text = I18n.t(text_locale, **additional_attributes) if I18n.exists?(text_locale)
    end
  end

  def additional_attributes
    @additional_attributes ||= {
      plate_number: parking_session&.vehicle&.plate_number || violation&.session&.vehicle&.plate_number,
      wallet_recharge_payment_amount: wallet_recharge_payment&.amount,
      parking_slot_number: parking_session&.parking_slot&.name,
      parking_lot_name: parking_session&.parking_lot&.name,
      session_payment_amount: payment&.amount,
      violation_type: violation&.rule&.name,
      minutes_extended: minutes_extended,
      wallet_amount: user.wallet.amount,
      user_full_name: user&.full_name,
      violation_id: violation&.id,
    }
  end

 def self.with_role_condition(user)
    scope = all

    case user.role.name.to_sym
    when :super_admin, :town_manager
      scope
    when :manager
      scope.includes(violation: { ticket: { agency: :managers } })
           .where(parking_tickets: { admin_id: user.id })
    when :officer
      scope.joins(violation: { ticket: { agency: :officers } } )
           
    else
      scope.none
    end
  end
end
