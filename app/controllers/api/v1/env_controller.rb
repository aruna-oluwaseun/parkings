module Api
  module V1
    class EnvController < ::Api::V1::ApplicationController
      before_action :authenticate_user!, except: %i[app_version]

      api :GET, '/api/v1/env/cardconnect_merchant_id_test', 'Get a merchant test ID'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def cardconnect_merchant_id_test
        render json: ENV['CARDCONNECT_MERCHANT_ID_TEST']
      end

      api :GET, '/api/v1/env/app_version', 'Get current App Version'

      def app_version
        render json: ENV.fetch("APP_VERSION") { 'NOT SET' }
      end

      api :GET, '/api/v1/env/cardconnect_merchant_id_production', 'Get a merchant production ID'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def cardconnect_merchant_id_production
        render json: ENV['CARDCONNECT_MERCHANT_ID_PRODUCTION']
      end

    end
  end
end
