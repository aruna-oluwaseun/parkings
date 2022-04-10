module Api
  module Dashboard
    module Reports
      module Detailed
        class VoiMatchesController < ApplicationController
          api :GET, '/api/dashboard/reports/detailed/voi_matches', 'Voi Matches detailed report'
          header :Authorization, 'Auth token', required: true
          param :pie_chart, Hash, 'Parking lot ids and date to configurate Pie Chart' do
            param :range, Hash, 'Date Range (calculated within the selected range)' do
              param :from, Integer, 'From date in timestamp (numeric) format', required: true
              param :to, Integer, 'To date in timestamp (numeric) format', required: true
            end
            param :parking_lot_ids, Array, 'Array of parking lots ID, if empty it will include all'
          end
          param :individual_lot, Hash, 'Parking lot ids and date to configurate Individual parking lot bar chart' do
            param :range, Hash, 'Date Range (calculated within the selected range)' do
              param :from, Integer, 'From date in timestamp (numeric) format', required: true
              param :to, Integer, 'To date in timestamp (numeric) format', required: true
            end
            param :parking_lot_ids, Array, 'Array of parking lots ID, if empty it will include all'
          end

          def index
            payload = ::Reports::Detailed::VoiMatches.run(params.merge(current_user: current_user))
            respond_with payload.result
          end
        end
      end
    end
  end
end
