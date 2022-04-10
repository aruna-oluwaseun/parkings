module Api
    module Dashboard
      module Reports
        module Detailed
          class VehiclesCurrentlyParkedController < ApplicationController
            api :GET, '/api/dashboard/reports/detailed/vehicles_currently_parked', 'Vehicles Currently Parked detailed report'
            header :Authorization, 'Auth token', required: true
            param :pie_chart, Hash, 'Parking lot ids and date to configurate Pie Chart' do
              param :range, Hash, 'Date Range (calculated within the selected range)' do
                param :from, Integer, 'From date in timestamp (numeric) format', required: true
                param :to, Integer, 'To date in timestamp (numeric) format', required: true
              end
              param :parking_lot_ids, Array, 'Array of parking lots ID, if empty it will include all'
            end

            def index
              payload = ::Reports::Detailed::VehiclesCurrentlyParked.run(params.merge(current_user: current_user))
              respond_with payload.result
            end
          end
        end
      end
    end
  end
