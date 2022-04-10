module Api
  module Dashboard
    module Parking
      class ViolationHistoryLogsController < ApplicationController
        api :GET, '/api/dashboard/parking/violations/:violation_id/violation_history_logs'
        header :Authorization, 'Auth token', required: true
        param :violation_id, Integer, 'Parking::Violation ID', required: false
        param :activity_log, String, 'Filter by changed attribute', required: false
        param :range, Hash, 'Date Range (all violation history logs created within the selected range)' do
          param :from, String, 'Date formatted %Y-%m-%d', required: false
          param :to, String, 'Date formatted %Y-%m-%d', required: false
        end

        def index
          parking_violation = ::Parking::Violation.includes(:ticket).find(params[:violation_id])
          authorize! parking_violation
          scope = Api::Dashboard::HistoryLogs::ViolationQuery.call(params.merge(parking_violation: parking_violation))
          respond_with paginate(scope, count: scope.size)
        end
      end
    end
  end
end
