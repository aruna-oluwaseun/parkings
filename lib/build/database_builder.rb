Dir[Rails.root.join('spec/support/faker/*.rb')].each do |f|
  require f
end

module Build
  class DatabaseBuilder
    def self.run
      new.execute
    end

    def execute
      ActiveRecord::Base.transaction do
        destroy_data

        create_roles
        create_test_admins
        create_agency_types
        create_agency
        create_parking_lots
        create_camera
        create_manufacturers
        create_kiosk_and_token
        create_ai_token
        create_reports

        if Rails.env.development? || Rails.env.test?
          User.destroy_all
          User.connection.reset_pk_sequence!(User.table_name)
          ['user@gmail.com', 'test@gmail.com'].each do |email|
            user = User.create(email: email, password: 'password', first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, confirmed_at: DateTime.now, phone: '+17526274136')
            CreditCard.create(number: '4788250000121443', holder_name: 'test', expiration_year: 23, expiration_month: 12, user: user)
            user.create_wallet
          end
        end

        User.find_each do |user|
          create_vehicles(user)
          create_sessions(user)
          create_notifications(user)
          create_dispute(user)
          create_messages(user)
          create_alert(user)
          create_payment(user)
        end

        create_ai_error
      end
    end

    private

    def destroy_data
      [
        ::Ai::ErrorReport,
        Payment,
        Parking::Ticket,
        Parking::Violation,
        Parking::VehicleRule,
        Agency,
        AgencyType,
        Dispute,
        CoordinateParkingPlan,
        ParkingSlot,
        ParkingLot,
        ParkingSession,
        Vehicle,
        Manufacturer,
        Camera,
        Admin,
        Message,
        Report,
        Role
      ].each do |klass|
        Rails.logger.info "Destroying #{klass.name}"
        klass.destroy_all
        klass.connection.reset_pk_sequence!(klass.table_name)
      end
    end

    def create_roles
      Rails.logger.info 'Executing RolesSeedCommand'
      RolesSeedCommand.execute
    end

    def create_test_admins
      Rails.logger.info 'Creating Test Admins'
      password = 'password'

      Admin.create!(
        email: "admin@example.com",
        password: password,
        username: "administrator",
        phone: Faker::Phone.number,
        status: 'active',
        name: "#{Faker::Name.first_name} #{Faker::Name.last_name}",
        role_id: Role.find_by(name: :super_admin).id
      )

      Role.where.not(name: :super_admin).each do |role|
        name =  "#{Faker::Name.first_name} #{Faker::Name.last_name}"
        phone = Faker::Phone.number
        Admin.create!(
          email: "admin.#{role.name}@telesoftmobile.com",
          password: password,
          phone: phone,
          username: "admin#{role.name.sub('_','')}",
          status: 'active',
          name: name,
          role_id: role.id
        )
      end
    end

    def create_agency
      Rails.logger.info 'Creating Agencies'
      agency = Agency.create!(
        name: 'Best agency',
        email: 'parking@telesoftmobile.com',
        managers: [Admin.manager.first],
        officers: [Admin.officer.first],
        agency_type: AgencyType.last
      )
      Location.create!(
        subject: agency,
        country: Faker::Address.country,
        city: Faker::Address.city,
        building: Faker::Address.building_number,
        street: Faker::Address.street_name,
        state: Faker::Address.state,
        ltd: Faker::Address.latitude.to_f,
        lng: Faker::Address.longitude.to_f,
        zip: Faker::Address.zip(Faker::Address.state_abbr)
      )
    end

    def create_parking_lots
      Rails.logger.info 'Creating ParkingLots'
      30.times.each do |i|
        lot = ParkingLot.create!(
          name: "Parking Lot ##{i}",
          email: 'parking@telesoftmobile.com',
          phone: Faker::Phone.number,
          outline: JSON.parse(File.read(Rails.root.join('spec/fixtures/parking_lot.parking'))),
          town_managers: [Admin.town_manager.first]
        )

        Location.create!(
          subject: lot,
          country: Faker::Address.country,
          city: Faker::Address.city,
          building: Faker::Address.building_number,
          street: Faker::Address.street_name,
          state: Faker::Address.state,
          ltd: Faker::Address.latitude.to_f,
          lng: Faker::Address.longitude.to_f,
          zip: Faker::Address.zip(Faker::Address.state_abbr)
        )
        Parking::Rule.names.values.each do |rule_name|
          Parking::Rule.create!(
            lot: lot,
            name: rule_name,
            description: Faker::Lorem.paragraph
          )
        end

        lot.spaces.each_with_index do |space, index|
          ParkingSlot.create!(name: space['space_id'], parking_lot: lot)
        end

        lot.create_setting!(
          incremental: 60.minutes.to_i,
          rate: 1.0,
          parked: 30.minutes.to_i,
          overtime: 30.minutes.to_i,
          period: 30.minutes.to_i,
          free: 10.minutes.to_i
        )
      end
    end

    def create_notifications(user)
      Rails.logger.info "Creating notifications for #{user.email}"
      user.parking_sessions.each do |session|
        4.times do
          [:car_parked, :car_entrance, :car_left, :car_exit].each do |template|
            user.notifications.create!(template: template, parking_session: session, text: Faker::Lorem.sentence)
          end
        end
      end

      User::Notification.last(3).each(&:destroy)
    end

    def create_messages(user)
      Rails.logger.info "creating messages for #{user.email}"
      4.times do
        [:invoice, :violation, :promotion].each do |template|
          user.messages.create!(subject: Dispute.all.sample, template: template, text: Faker::Lorem.sentence, author: Admin.first, to: user)
        end
      end
      Message.last(3).each { |message| message.update(read: true) }
    end

    def create_dispute(user)
      puts "creating dispute for #{user.email}" if Rails.env.production?
      user.parking_sessions.each do |session|
        4.times do
          [:time, :other, :not_me].each do |reason|
            dispute = user.disputes.create!(reason: reason, parking_session: session, admin: Admin.first)
            user.messages.create!(subject: dispute, template: :dispute, text: Faker::Lorem.sentence, author: Admin.first, to: user)
          end
        end
      end
    end

    def create_vehicles(user)
      Rails.logger.info "Creating vehicles for #{user.email}"
      5.times do |i|
        user.vehicles.create!(
          plate_number: Faker::Car.number,
          color: Faker::Vehicle.color,
          vehicle_type: Faker::Vehicle.car_type,
          manufacturer: Manufacturer.order(Arel.sql('RANDOM()')).first,
          model: Faker::Vehicle.model
        )
      end
    end

    def create_manufacturers
      %i(Toyota Hyundai Honda Kia Nissan Mazda).each do |manufacturer|
        Manufacturer.create(name: manufacturer)
      end
    end

    def create_sessions(user)
      Rails.logger.info "Creating sessions for #{user.email}"
      # current sessions
      lot = ParkingLot.first
      occupied_slots = lot.parking_slots.limit(25)
      occupied_slots.update_all(status: :occupied)
      options = {
        vehicle: user.vehicles.first,
        parking_lot: lot
      }
      t = Time.now
      occupied_slots.each do |slot|
        created_at = rand(2.years).seconds.ago
        ParkingSession.create!(
          options.merge(
            uuid: SecureRandom.hex(10),
            check_in: t - 5.minutes,
            entered_at: t - 5.minutes,
            check_out: t + 25.minutes,
            status: :confirmed,
            parking_slot: slot,
            fee_applied: lot.rate,
            parked_at: created_at,
            created_at: created_at
          )
        )
      end

      # previous sessions
      25.times do |i|
        created_at = rand(2.weeks).seconds.ago
        session = ParkingSession.create!(
          options.merge(
            uuid: SecureRandom.hex(10),
            check_in: t - (i + 1).days,
            check_out: t - (i + 1).days + 30.minutes,
            status: :finished,
            fee_applied: lot.rate,
            parking_slot: occupied_slots.sample,
            parked_at: created_at,
            created_at: created_at
          )
        )
        create_tickets(session) if i % 3
      end

      5.times.each do |i|
        session = ParkingSession.create!(
          options.merge(
            uuid: SecureRandom.hex(10),
            status: :finished,
            created_at: rand(2.weeks).seconds.ago,
            entered_at: t - 5.minutes,
          )
        )
      end
    end

    def create_alert(user)
      Rails.logger.info "Creating alert for #{user.email}"
      session = user.parking_sessions.current.first
      if session
        user.alerts.create!(
          subject: session
        )
      end
    end

    def create_camera
      Rails.logger.info "Creating camera"
      ParkingLot.first.cameras.create!(
        name: 'Camera 1',
        stream: 'rtsp://76.72.141.53/MediaInput/stream_1',
        login: :admin,
        password: 'ZAQ!2wsx',
        vmarkup: JSON.parse(File.read(Rails.root.join('spec/fixtures/camera.vmarkup')))
      )
    end

    def create_ai_token
      Ai::Token.create(name: 'ai_token', value: 'deaff2f8e11ba89531df53c2729b258edeaff2f8e11ba89531df53c2729b258edeaff2f8e11ba895')
    end

    def create_kiosk_and_token
      Rails.logger.info "creating kiosk token"

      kiosk = Kiosk.create!(
        parking_lot: ParkingLot.first
      )
      Ksk::Token.create!(
        kiosk: kiosk,
        name: 'Test token',
        value: 'f9ec6bc77de0507e7302639d6b46a3d79fbe99de6df791cfbe91bb5b68c04abb8f0130a22bd13da2'
      )
    end

    def create_payment(user)
      Rails.logger.info "creating payment for #{user.email}"

      user.parking_sessions.last(3).each do |parking_session|
        if parking_session.finished?
          Payment.create(
            amount: 50,
            payment_method: :cash,
            status: :success,
            parking_session: parking_session
          )
        end
      end
    end

    def create_tickets(session)
      Rails.logger.info "creating tickets for session #{session.id}"

      parking_violation = Parking::Violation.create!({
        session: session,
        rule: Parking::Rule.first,
        vehicle_rule: Parking::VehicleRule.create(lot: session.parking_lot, vehicle_id: session.vehicle_id)
      })

      Parking::Ticket.create!({
        admin: Admin.officer.first,
        agency: Agency.first,
        status: Faker::Number.between(0, 1),
        violation: parking_violation,
        created_at: rand(2.years).seconds.ago
      })
    end

    def create_reports
      20.times do
        Report.create(
          name: "Report #{Faker::Company.name}",
          type: [Agency.first, ParkingLot.first, Vehicle.first].sample,
          created_at: rand(2.years).seconds.ago
        )
      end
    end

    def create_ai_error
      t = Time.now.utc.beginning_of_day
      parking_session_ids = ParkingSession.all.map(&:id)

      10.times do
        Rails.logger.info '::Ai::ErrorReport'
        ::Ai::ErrorReport.create(
          parking_session_id: parking_session_ids.sample,
          created_at: t
        )
      end

      15.times do
        Rails.logger.info '::Ai::ErrorReport'
        ::Ai::ErrorReport.create(
          parking_session_id: parking_session_ids.sample,
          created_at: t-1.day
        )
      end

      70.times do
        Rails.logger.info '::Ai::ErrorReport'
        ::Ai::ErrorReport.create(
          created_at: (t.beginning_of_week.to_date...t.end_of_week.to_date).to_a.sample,
          parking_session_id: parking_session_ids.sample
        )
      end

      50.times do
        Rails.logger.info '::Ai::ErrorReport'
        ::Ai::ErrorReport.create(
          created_at: ((t - 1.week).beginning_of_week.to_date...(t - 1.week).end_of_week.to_date).to_a.sample,
          parking_session_id: parking_session_ids.sample
        )
      end

      70.times do
        Rails.logger.info '::Ai::ErrorReport'
        ::Ai::ErrorReport.create(
          created_at: (t.beginning_of_month.to_date...t.end_of_month.to_date).to_a.sample,
          parking_session_id: parking_session_ids.sample
        )
      end

      50.times do
        Rails.logger.info '::Ai::ErrorReport'
        ::Ai::ErrorReport.create(
          created_at: ((t - 1.month).beginning_of_month.to_date...(t - 1.month).end_of_month.to_date).to_a.sample,
          parking_session_id: parking_session_ids.sample
        )
      end
    end

    def create_agency_types
      ::AgencyType.create(
        ::AgencyType::DEFAULT_NAMES.map { |agency_type_name| { name: agency_type_name } }
      )
    end
  end
end
