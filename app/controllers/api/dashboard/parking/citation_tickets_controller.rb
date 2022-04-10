module Api
  module Dashboard
    module Parking
      class CitationTicketsController < ApplicationController
        api :GET, '/api/dashboard/parking/citation_tickets'
        header :Authorization, 'Auth token', required: true
        param :per_page, Integer,
              'Items per page count, default is 10. Check response headers for total count (key: X-Total)',
              required: false
        param :id, Integer, 'Citation Ticket id/unique number'
        param :page, Integer, 'Items page number'
        param :range, Hash, 'Date Range (all citation tickets created within the selected range)' do
          param :from, Integer, 'From date in timestamp (numeric) format', required: true
          param :to, Integer, 'To date in timestamp (numeric) format', required: false
        end
        param :status, ::Parking::CitationTicket.statuses.keys, required: false
        param :parking_lot_id, Integer, 'Parking Lot id/unique number', required: false
        param :violation_type, ::Parking::Rule.names.keys, required: false
        param :officer_id, Integer, 'Admin id/unique number', required: false

        def index
          scope = paginate CitationTicketsQuery.call(params.merge(user: current_user))
          respond_with scope, each_serializer: Api::Dashboard::Parking::ThinCitationTicketSerializer
        end

        api :POST, '/api/dashboard/parking/citation_tickets', 'Create Citation Ticket'
        header :Authorization, 'Auth token', required: true
        param :citation_ticket, Hash, 'Parking Citation Ticket', required: true do
          param :status, ::Parking::CitationTicket.statuses.keys, 'Citation Ticket status', required: false
          param :plate_number, String, 'License plate number', required: true
          param :parking_violation, Hash, 'Parking Violation', required: true do
            param :agency_id, Integer, 'Agency number of where the creator is assigned to or belongs to', required: true
            param :officer_id, Integer, 'Only the Meter Enforcement Officers of the Agency where the VR Ticket belongs to'
            param :images, Array, 'Violation images array in base64', required: false
            param :parking_lot, Hash, 'Parking Lot Data', required: true do
              param :id, Integer, 'Parking Lot Id', required: true
            end
            param :parking_rule, Hash, 'Violation Type Data', required: true do
              param :name, ::Parking::Rule.names.keys, required: true
            end
            param :ticket, Hash, 'Parking Ticket Data', required: false do
              param :officer_id, Integer, 'ID of the officer of the Agency where the VR Ticket belongs to', required: false
            end
          end
        end

        def create
          authorize! ::Parking::CitationTicket
          result = ::Parking::CitationTickets::Create.run(citation_ticket: params.fetch(:citation_ticket, {}))
          respond_with result.result, serializer: Api::Dashboard::Parking::CitationTicketSerializer
        end

        api :GET, '/api/dashboard/parking/citation_tickets/:id', 'Fetch Citation Ticket details'
        param :id, Integer, required: true
        header :Authorization, 'Auth token', required: true

        def show
          citation_ticket = ::Parking::CitationTicket.find(params[:id])
          authorize! citation_ticket
          respond_with citation_ticket, serializer: ::Api::Dashboard::Parking::CitationTicketSerializer
        end

        api :PUT, '/api/dashboard/parking/citation_tickets/:id', 'Update Citation Ticket Report (specify only fields we want to update)'
        param :id, Integer, required: true
        header :Authorization, 'Auth token', required: true
        param :vehicle, Hash, required: false do
          param :plate_number, String, 'Vehicle LPN', required: true
        end
        param :citation_ticket, Hash, required: true do
          param :status, ::Parking::CitationTicket.statuses.keys, required: true
          param :images, Array, 'Citation Ticket images array in base64', required: false
          param :images_ids, Array, 'IDs of images that should be deleted', required: false
        end

        def update
          citation_ticket = ::Parking::CitationTicket.find(params[:id])
          authorize! citation_ticket
          payload = params.fetch(:citation_ticket, {}).merge(object: citation_ticket, user: current_user, plate_number: params.dig(:vehicle, :plate_number))
          result = ::Parking::CitationTickets::Update.run(payload)
          respond_with result, serializer: ::Api::Dashboard::Parking::CitationTicketSerializer
        end
      end
    end
  end
end
