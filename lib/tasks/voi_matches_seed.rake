namespace :voi_matches do
  desc "Seeding voi matches"
  task seed: :environment do
    today_date_range = Time.now.at_beginning_of_day..Time.now.end_of_day
    current_week_date_range = Time.now.at_beginning_of_week..Time.now.end_of_week
    next_week_date_range = Time.now.next_week.at_beginning_of_week..Time.now.next_week.end_of_week
    last_month_date_range = Time.now.last_month.at_beginning_of_month..Time.now.last_month.end_of_month
    next_month_date_range = Time.now.next_month.at_beginning_of_month..Time.now.next_month.end_of_month

    CREATED_AT_DATES = [
      today_date_range,
      current_week_date_range,
      next_week_date_range,
      last_month_date_range,
      next_month_date_range
    ].freeze

    PARKING_TICKET_STATUSES = [0,1,2]

    clean_up_seeds

    ActiveRecord::Base.transaction do
      seed_vio_matches
    end
  end

  def seed_vio_matches
    ParkingLot.take(15).each do |parking_lot|
      CREATED_AT_DATES.each do |date|
        4.times do
          vehicle = create_vehicle
          session = parking_sessions(vehicle.id, parking_lot.id)
          voi_match = create_voi_match(parking_lot, vehicle, date)
          add_parking_violation(voi_match, parking_lot, session, date)
        end
      end
    end
  end

  def create_vehicle
    user = User.find(1)
    user.vehicles.create!(
      color: "green",
      vehicle_type: "car",
      model: "supermodel"
    )
  end

  def add_parking_violation(voi_match, parking_lot, session, date)
    parking_rule = Parking::Rule.create(name: 0, description: "Perferendis fugit ea. Sit sunt et. Vitae ut rerum.", agency_id: 1, lot: parking_lot)
    violation = voi_match.create_violation(
      description: "some description",
      session: session,
      rule: parking_rule,
      created_at: date
    )
    parking_ticket(violation)
  end

  def parking_sessions(vehicle_id, lot_id)
    ParkingSession.create(
      vehicle_id: vehicle_id,
      parking_lot_id: lot_id,
      ai_status: "entered",
      uuid: SecureRandom.hex,
      status: "created"
    )
  end

  def parking_ticket(violation)
    violation.create_ticket(admin_id: 1, status: PARKING_TICKET_STATUSES.sample)
  end

  def clean_up_seeds
    ActiveRecord::Base.transaction do
      Parking::Violation.all.destroy_all
      Parking::VehicleRule.destroy_all
    end
  end

  def create_voi_match(parking_lot, vehicle, date)
    parking_lot.vehicle_rules.create(color: "green", vehicle_type: "car", vehicle_id: vehicle.id, created_at: date)
  end
end
