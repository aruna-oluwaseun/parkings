module Api
  module Meo
    module V1
      class AuthController < ::Api::Meo::V1::ApplicationController
        ### Uncomment string below if you add child controllers to ::Api::Meo::V1::ApplicationController
        # skip_before_action :authenticate_admin!, only: %i(sign_in)

        wrap_parameters :admin

        api :POST, '/api/meo/v1/auth/sign_in', 'Admin sign in'
        param :admin, Hash do
          param :username, String, 'Email or username', required: true
          param :password, String, required: true
        end

        def sign_in
          result = ::Admins::SignIn.run(params.fetch(:admin, {}).merge( { requester_type: 'meo' } ))
          respond_with result
        end

      end
    end
  end
end
