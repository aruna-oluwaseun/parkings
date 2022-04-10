class PaymentMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/payment_mailer/payment_successful
  def payment_successful
    PaymentMailer.payment_successful(current_session, current_session_payment)
  end

  # Accessible from http://localhost:3000/rails/mailers/payment_mailer/payment_failure
  def payment_failure
    PaymentMailer.payment_failure(current_session)
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
        zip: Faker::Address.zip(Faker::Address.state_abbr)
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

  def current_session_payment
    Payment.new(amount: 20, parking_session: current_session)
  end
end
