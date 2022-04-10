module Api
  module Meo
    module V1
      class ApplicationController < ::Api::ApplicationController

        ### Uncomment code below if you add child controllers

        # before_action :authenticate_admin!
        # before_action :set_paper_trail_whodunnit

        # def authenticate_admin!
        #   return unauthorized! unless current_user
        #   return account_suspended! unless current_user.active?
        # end

        # def current_user
        #   @current_user ||= Authorizer.authorize_by_token(request.headers['Authorization'], Admin)
        # end

      end
    end
  end
end
