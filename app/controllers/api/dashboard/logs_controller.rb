module Api
  module Dashboard
    class LogsController < ApplicationController
      api :GET, '/api/dashboard/logs/session_log', 'Get manufacturers list'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def show
        log = "logs/dashboard/#{params[:id].gsub('-','/')}".classify.constantize.new(params)
        respond_with log.search
      end
    end
  end
end
