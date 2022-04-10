module Api
  module Dashboard
    class PaymentsController < ApplicationController
      api :GET, '/api/dashboard/payments', 'Payments list'
      header :Authorization, 'Auth token from users#sign_in', required: true
      param :username, String, 'Username of Vehicle Owner'
      param :plate_number, Integer, 'Plate Number of Vehicle'
      param :parking_lot_name, Integer, 'Parking Lot Name'
      param :amount, Integer, 'Amount Paid'
      param :status, Integer, 'Payment Status'
      param :created_at, Integer, 'Date payment was initiated'

      def index
        authorize!
        scope = paginate PaymentsIndexQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: PaymentSerializer
      end
    end
  end
end
