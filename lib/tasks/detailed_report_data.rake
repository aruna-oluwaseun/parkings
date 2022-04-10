namespace :detailed_report do
  desc "Creating test data for all reports"
  task seed_data: :environment do
    @date_from = Date.parse(ENV.fetch('DATE_FROM') { '2020-06-01' })
    @date_to = Date.parse(ENV.fetch('DATE_TO') { '2020-06-30' })
    CREATED_AT_DATES = (@date_from..@date_to).to_a

    PARKING_TICKET_STATUSES = Parking::Ticket.statuses.values
    PARKING_RULE_NAMES = Parking::Rule.names.values

    ActiveRecord::Base.transaction do
      puts "Creating parking lots..." if Rails.env.development?
      create_parking_lots
      @parking_lots ||= create_parking_lots
      puts "Parking lots were created!" if Rails.env.development?

      puts "Creating parked vehicles..." if Rails.env.development?
      create_parked_vehicles
      puts "Parked vehicles were created!" if Rails.env.development?

      puts "Creating revenues..." if Rails.env.development?
      create_revenues
      puts "Revenues were created" if Rails.env.development?

      puts "Creating VOI matches and Violations" if Rails.env.development?
      seed_voi_matches_and_violations
      puts "VOI matches and Violations were created" if Rails.env.development?
    end
  end

  def seed_voi_matches_and_violations
    @parking_lots.each do |parking_lot|
      20.times do
        CREATED_AT_DATES.each do |date|
          vehicle = create_vehicle
          session = create_parking_sessions(vehicle.id, parking_lot.id)
          voi_match = create_voi_match(parking_lot, vehicle, date)
          voi_match.save!
          add_parking_violation(voi_match, parking_lot, session, date)
        end
      end
    end
  end

  def create_vehicle
    user = User.first
    user.vehicles.create!(
      color: "green",
      vehicle_type: "car",
      model: "supermodel"
    )
  end

  def add_parking_violation(voi_match, parking_lot, session, date)
    parking_rule = Parking::Rule.create(
      name: PARKING_RULE_NAMES.sample,
      description: "Perferendis fugit ea. Sit sunt et. Vitae ut rerum.",
      agency_id: 1,
      lot: parking_lot
    )
    violation = voi_match.create_violation(
      description: "some description",
      session: session,
      rule: parking_rule,
      created_at: date
    )
    parking_ticket(violation)
  end

  def create_parking_sessions(vehicle_id, parking_lot_id, status="created", created_at=Time.now)
    ParkingSession.create(
      vehicle_id: vehicle_id,
      parking_lot_id: parking_lot_id,
      ai_status: "entered",
      uuid: SecureRandom.hex,
      status: status
    )
  end

  def parking_ticket(violation)
    violation.create_ticket(admin_id: 1, status: PARKING_TICKET_STATUSES.sample)
  end

  def create_voi_match(parking_lot, vehicle, date)
    parking_lot.vehicle_rules.create(color: "green", vehicle_type: "car", vehicle_id: vehicle.id, created_at: date)
  end

  def create_parking_lots
    parking_lots = []
    6.times do
      parking_lots << ParkingLots::Create.run(build_parking_lot_params).object
    end
    parking_lots
  end

  def create_parked_vehicles
    @parking_lots.each do |parking_lot|
      CREATED_AT_DATES.each do |date|
        20.times do
          vehicle = create_vehicle
          session = create_parking_sessions(vehicle.id, parking_lot.id, "finished", created_at: date)
        end
      end
    end
  end

  def create_revenues
    @parking_lots.each do |parking_lot|
      CREATED_AT_DATES.each do |date|
        20.times do
          vehicle = create_vehicle
          session = create_parking_sessions(vehicle.id, parking_lot.id, "finished", created_at: date)
          Payment.create(
            amount: Faker::Number.decimal(2).to_f,
            parking_session_id: session.id,
            status: "success",
            created_at: date,
            payment_method: Payment.payment_methods.values.sample
          )
        end
      end
    end
  end

  def build_parking_lot_params
    @parking_admin_id ||= Admin.joins(:role).where("roles.name": 'parking_admin').last.id
    @town_manager_id ||= Admin.joins(:role).where("roles.name": 'town_manager').last.id

    {
      email: Faker::Internet.email,
      phone: '+15417543010',
      rate: 1.5,
      name: Faker::Address.street_name,
      outline: Base64.encode64(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))),
      location: {
        country: Faker::Address.country,
        city: Faker::Address.city,
        building: Faker::Address.building_number,
        state: Faker::Address.state,
        street: Faker::Address.street_name,
        zip: Faker::Address.zip(Faker::Address.state_abbr),
        ltd: Faker::Address.latitude,
        lng: Faker::Address.longitude
      },
      parking_admin_id: @parking_admin_id,
      avatar: nil,
      status: 'active',
      town_manager_id: @town_manager_id,
      rules: [
        {
          name: ::Parking::Rule.names.keys[0],
          status: false
        }
      ]
    }.with_indifferent_access
  end
end
