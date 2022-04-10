module Api
  module V1
    class DropdownsController < ApplicationController

      api :GET, '/api/v1/dropdowns/states_list', 'Dropdowns with all the countries and his alpha 2 code'
      param :country_code, String, "Param for state_list endpoint", required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/v1/dropdowns/countries_list', 'Dropdowns with all the countries and his alpha 2 code'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/v1/dropdowns/manufacturers_list', 'Dropdowns values'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/v1/dropdowns/payment_parking_lot_filter', 'Dropdowns values'
      param :user_email, Integer, 'Current user email', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/v1/dropdowns/notification_types_list', 'Dropdowns with all the notification types'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def show
        dropdown_field = "dropdown_fields/mobile/#{params[:dropdown_class].gsub('-','/')}".classify.constantize.new(params)
        respond_with dropdown_field.search
      end

    end
  end
end
