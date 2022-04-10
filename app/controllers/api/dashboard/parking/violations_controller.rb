module Api
  module Dashboard
    module Parking
      class ViolationsController < ApplicationController
        api :GET, '/api/dashboard/parking/violations'
        header :Authorization, 'Auth token', required: true
        param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
        param :page, Integer, 'Items page number', required: false
        param :range, Hash, 'Date Range (all violations created within the selected range)' do
          param :from, Integer, 'From date in timestamp (numeric) format', required: true
          param :to, Integer, 'To date in timestamp (numeric) format', required: false
        end
        param :ticket_status, ::Parking::Ticket.statuses.keys, required: false
        param :parking_lot_id, Integer, 'Parking Lot id/unique number', required: false
        param :agency_id, Integer, 'Agency id/unique number', required: false
        param :ticket_id, Integer, 'Parking Ticket id/unique number', required: false
        param :violation_type, ::Parking::Rule.names.keys, required: false
        param :officer_id, Integer, 'Admin id/unique number', required: false

        def index
          authorize! ::Parking::Violation
          scope = paginate ::Api::Dashboard::ParkingViolationsQuery.call(params.merge(user: current_user))
          respond_with scope, each_serializer: ::Api::Dashboard::Parking::DetailedViolationSerializer
        end

        api :GET, '/api/dashboard/parking/violations/:id', 'Fetch Violation Report details'
        param :id, Integer, required: true
        header :Authorization, 'Auth token', required: true

        def show
          violation = ::Parking::Violation.find(params[:id])
          authorize! violation
          respond_with violation, serializer: ::Api::Dashboard::Parking::DetailedViolationSerializer
        end

        api :PUT, '/api/dashboard/parking/violations/:id', 'Update Violation Report (specify only fields we want to update)'
        param :id, Integer, required: true
        header :Authorization, 'Auth token', required: true
        param :parking_violation, Hash, required: true do
          param :status, ::Parking::Ticket.statuses.keys, required: false
          param :admin_id, Integer, 'ID of the officer of the Agency where the VR Ticket belongs to', required: false
          param :violation_type, ::Parking::Rule.names.keys, desc: 'Parking rule name', required: false
          param :images, Array, 'Violation images array in base64', required: false
          param :images_ids, Array, 'IDs of images that should be deleted', required: false
        end

        def update
          violation = ::Parking::Violation.find(params[:id])
          authorize! violation
          payload = params.fetch(:parking_violation, {}).merge(object: violation, user: current_user)
          result = ::Parking::Violations::Update.run(payload)
          respond_with result, serializer: ::Api::Dashboard::Parking::DetailedViolationSerializer
        end
      end
    end
  end
end
