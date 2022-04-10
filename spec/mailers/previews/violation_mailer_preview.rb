class ViolationMailerPreview < ActionMailer::Preview

  # Accessible from http://localhost:3000/rails/mailers/violation_mailer/commited
  def commited
    ViolationMailer.commited('test@test.com', current_session_violation)
  end

  # Accessible from http://localhost:3000/rails/mailers/violation_mailer/canceled
  def canceled
    ViolationMailer.canceled(current_session.vehicle.user, current_session_violation)
  end

  private

  def current_session
    parking_lot = ParkingLot.new(
      email: 'parkinglot@admin.com',
      name: 'Parking Lot Easton',
      location: Location.new(
        country: Faker::Address.country,
        city: Faker::Address.city,
        building: Faker::Address.building_number,
        street: Faker::Address.street_name,
        state: Faker::Address.state,
        ltd: Faker::Address.latitude.to_f,
        lng: Faker::Address.longitude.to_f,
        zip: Faker::Address.zip(Faker::Address.state_abbr),
        full_address: "#{Faker::Address.street_name} #{Faker::Address.building_number}, #{Faker::Address.city}, USA, 55555"
      ),
      setting: Parking::Setting.new(
        rate: 1.0,
        parked: 40.minutes.to_i,
        overtime: 30.minutes.to_i,
        period: 30.minutes.to_i,
        free: 10.minutes.to_i
      )
    )
    session = ParkingSession.new(
      id: 1,
      check_out: 1.hour.from_now,
      parked_at: DateTime.now,
      vehicle: Vehicle.new(
        plate_number: 'ABC-1234',
        user: User.new(
          email: 'test@test.com',
          first_name: 'John',
          wallet: Wallet.new(amount: 205)
        )
      ),
      parking_lot: parking_lot,
      parking_slot: ParkingSlot.new(
        name: '42',
        parking_lot: parking_lot
      )
    )
  end

  def current_session_violation
    Parking::Violation.new(
      description: 'Some desription',
      session: current_session,
      rule: Parking::Rule.new(
        lot: current_session.parking_lot,
        agency: Agency.new(
          name: 'SuperAgency',
          email: 'test@agency.com'
        )
      ),
      created_at: Time.now
    )
  end
end
