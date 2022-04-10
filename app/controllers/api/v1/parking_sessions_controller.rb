module Api
  module V1
    class ParkingSessionsController <  ApplicationController
      before_action :authenticate_user!

      api :GET, '/api/v1/parking_sessions', 'Get user parking session previews list'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      header :Authorization, 'Auth token from users#sign_in', required: true

      def index
        respond_with paginate(scope), each_serializer: serializer
      end

      api :GET, '/api/v1/parking_sessions/current', 'Get user current parking session'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def current
        return not_found! unless current_session
        respond_with current_session, each_serializer: serializer
      end

      api :GET, '/api/v1/parking_sessions/:id/payment', 'Payment calculator'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :check_out, Integer, 'Expected check out time in seconds'

      def payment
        session = ParkingSession.find(params[:id])
        authorize! session
        session.check_out = Time.at(params[:check_out].to_i) if params[:check_out].present?
        respond_with session, serializer: PaymentInfoSerializer
      end

      api :GET, '/api/v1/parking_session/:id', 'Get user parking session details'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :id, Integer, 'Parking session id', required: true

      def show
        session = scope.find(params[:id])
        respond_with session, serializer: serializer
      end

      api :GET, '/api/v1/parking_sessions/recent', 'Get last 5 parking history'
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      header :Authorization, 'Auth token from users#sign_in', required: true

      def recent
        recent_scope = paginate current_user.parking_histories.joins(:parking_session).order("parking_sessions.check_in desc").includes(:parking_session)
        respond_with recent_scope.map(&:parking_session), each_serializer: serializer
      end

      api :POST, '/api/v1/parking_sessions/:id/pay', 'Pay for the parking session'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :check_out, Integer, 'Expected check out time in seconds', required: true
      param :id, Integer, 'Parking session id', required: true
      param :gateway, ['wallet'], 'Gateway name to use',  required: false

      def pay
        session = ParkingSession.with_preloaded.find(params[:id])
        authorize! session
        result = ParkingSessions::Confirm.run(
          object: session,
          check_out: params.dig(:check_out),
          gateway: params.dig(:gateway)
        )
        if result.valid?
          respond_with result.object.payments.last
        else
          respond_with result
        end
      end

      api :PUT, '/api/v1/parking_sessions/:id/pay_later', 'Pay for the parking session'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :check_out, Integer, 'Expected check out time in seconds', required: true
      param :id, Integer, 'Parking session id', required: true
      param :alert_id, Integer, 'alert id to be resolved', required: true

      def pay_later
        session = ParkingSession.with_preloaded.find(params[:id])
        authorize! session
        current_user.alerts.find(params.dig(:alert_id)).resolved!
        session.update(check_out: Time.at(params.dig(:check_out).to_i))
        respond_with session, serializer: serializer
      end

      api :PUT, '/api/v1/parking_sessions/:id/toggle_permanence', 'Block/unblock session to not allow to finish session'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :id, Integer, 'Parking session id', required: true

      def toggle_permanence
        session = ParkingSession.with_preloaded.find(params[:id])
        session.update(permanent: !session.permanent)
        respond_with session, serializer: serializer
      end

      private

      def serializer
        Api::V1::ParkingSessionSerializer
      end

      def current_session
        @current_session ||= scope.current.where(parking_slot_id: parking_lot.parking_slot_ids)
      end

      def scope
        ParkingSession.with_preloaded.where(vehicle_id: current_user.vehicle_ids)
      end

      def parking_lot
        @parking_lot ||= ParkingLot.first # temp
      end
    end
  end
end
