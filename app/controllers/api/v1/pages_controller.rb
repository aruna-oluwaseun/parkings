module Api
  module V1
    class PagesController < ApplicationController

      api :GET, '/api/v1/pages/privacy_policy', 'Get Privacy Policy content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/v1/pages/contact_us', 'Get Contact Us content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, 'api/v1/pages/faq', 'Get FAQ content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/v1/pages/about_us', 'About Park Smart content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, '/api/v1/pages/meo_contact_details', 'Get Meo contact details'
      header :Authorization, 'Auth token from users#sign_in', required: true

      api :GET, 'api/v1/pages/faq', 'Get FAQ content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def show
        page = params[:id]
        content = I18n.t("pages.#{page}")
        render json: content
      end

      api :GET, '/api/v1/pages/home', 'Get Contact Us content'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def home
        render json: {
          homepage_video: "https://youtu.be/Q_90ZlygfGI"
        }
      end

    end
  end
end
