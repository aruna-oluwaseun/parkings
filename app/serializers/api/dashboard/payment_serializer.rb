module Api
  module Dashboard
    class PaymentSerializer < ::ApplicationSerializer
      attributes :id, :amount, :status, :parking_session, :created_at

      def parking_session
        session = object.parking_session

        { id: session.id }.tap do |hash|
          hash[:vehicle] = session.vehicle.as_json(only: [:id, :plate_number, :user_id])
          hash[:user] = session.user.as_json(only: [:id, :first_name])
          hash[:parking_lot] = session.parking_lot.as_json(only: [:name])
        end
      end

    end
  end
end
