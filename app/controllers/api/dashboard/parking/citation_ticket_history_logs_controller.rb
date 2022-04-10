module Dashboard
    module Parking
      class CitationTicketHistoryLogsController < ApplicationController
        api :GET, '/api/dashboard/parking/citation_tickets/:citation_ticket_id/citation_ticket_history_logs'
        header :Authorization, 'Auth token', required: true
        param :citation_ticket_id, Integer, 'Parking::CitationTicket ID', required: false
        param :activity_log, String, 'Filter by changed attribute', required: false
        param :range, Hash, 'Date Range (all citation ticket history logs created within the selected range)' do
          param :from, String, 'Date formatted %Y-%m-%d', required: false
          param :to, String, 'Date formatted %Y-%m-%d', required: false
        end

        def index
          citation_ticket = ::Parking::CitationTicket.find(params[:citation_ticket_id])
          scope = ::HistoryLogs::CitationTicket.run(citation_ticket: citation_ticket).result
          respond_with paginate(scope, count: scope.size)
        end
      end
    end
  end
end
