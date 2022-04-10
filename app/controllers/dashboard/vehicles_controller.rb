module Dashboard
  class VehiclesController < AdministrateController
    after_action :check_errors, only: %i[park_car car_enter_lot car_exit_lot car_exit_slot]

    def search
      if params[:search].present?
        if params[:accuarate] == "1"
          resources = scoped_resource.where(plate_number: params[:search]) if params[:search].present?
        else
          resources = scoped_resource.where("plate_number ilike ?", "%#{params[:search]}%") if params[:search].present?
        end
      else
        resources = scoped_resource
      end
      resources = apply_resource_includes(resources)
      resources = order.apply(resources)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)
      render :index, locals: {
        resources: resources,
        search_term: '',
        page: page,
        show_search_bar: show_search_bar?,
      }
    end

    def reset_sessions
      vehicle = Vehicle.find(params[:id])
      vehicle.parking_sessions.where.not(status: :finished).each do |session|
        payload = {
          parking_lot: ParkingLot.first,
          timestamp: DateTime.now.to_i,
          uuid: session.uuid
        }
        ::ParkingSessions::CarExit.run(payload)
      end
      redirect_to dashboard_vehicle_path(vehicle)
    end

    def park_car
      vehicle = Vehicle.find(params[:id])
      session = vehicle.parking_sessions.where.not(status: [:finished, :confirmed], ai_status: :parked).first
      payload = {
        parking_lot: ParkingLot.first,
        parking_slot_id: ParkingLot.first.parking_slots.free.first&.name.to_s,
        plate_number: vehicle.plate_number,
        timestamp: DateTime.now.to_i,
        uuid: session&.uuid || SecureRandom.uuid
      }

      @result = ::ParkingSessions::CarParked.run(payload)
      redirect_to dashboard_vehicle_path(vehicle)
    end

    def car_enter_lot
      vehicle = Vehicle.find(params[:id])
      parking_lot = ParkingLot.first
      payload = {
        timestamp: DateTime.now.to_i,
        parking_lot: parking_lot,
        uuid: SecureRandom.uuid,
        event_type: 'car_entrance',
        plate_number: vehicle.plate_number,
        color: vehicle.color,
        vehicle_type: vehicle.vehicle_type,
      }

      @result = ::ParkingSessions::CarEntrance.run(payload)
      redirect_to dashboard_vehicle_path(vehicle)
    end

    def car_exit_lot
      vehicle = Vehicle.find(params[:id])
      session = vehicle.parking_sessions.where.not(status: :finished).first
      payload = {
        parking_lot: session.parking_lot,
        timestamp: DateTime.now.to_i,
        uuid: session.uuid,
        event_type: 'car_exit',
        plate_number: vehicle.plate_number,
        color: vehicle.color,
        vehicle_type: vehicle.vehicle_type,
      }

      @result = ::ParkingSessions::CarExit.run(payload)
      redirect_to dashboard_vehicle_path(vehicle)
    end

    def car_exit_slot
      vehicle = Vehicle.find(params[:id])
      session = vehicle.parking_sessions.where.not(status: :finished).first
      payload = {
        parking_lot: session.parking_lot,
        timestamp: DateTime.now.to_i,
        uuid: session.uuid,
        event_type: 'car_left',
        plate_number: vehicle.plate_number,
        color: vehicle.color,
        vehicle_type: vehicle.vehicle_type,
      }

      @result = ::ParkingSessions::CarLeft.run(payload)
      redirect_to dashboard_vehicle_path(vehicle)
    end

    def valid_action?(name, resource = resource_class)
      %w[destroy].exclude?(name.to_s) && super
    end

    private

    def check_errors
      errors = []
      if @result.errors.any?
        @result.errors.messages.each do |key, messages|
          messages.map { |message| errors.push(message) }
        end
      end
      if errors.any?
        flash[:alert] = errors.to_sentence
      else
        flash[:success] = 'Success'
      end
    end
  end
end
