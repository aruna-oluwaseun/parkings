module Api
  module Dashboard
    class PdfPagesController < ::Api::Dashboard::ApplicationController
      api :GET, '/api/dashboard/pdf_pages/download', 'Download page as PDF'
      header :Authorization, 'Auth token', required: true
      param :page_url, String, 'HTML page URL', required: true

      def download
        pdf_page = ::Dashboard::GeneratePdfPage.call(request.referer, params[:page_url], auth_token)
        send_data pdf_page
      end

      private
      # @overload auth_token
      # This method returns auth token from request headers
      # @return [String]
      def auth_token
        request.headers['Authorization']
      end
    end
  end
end
