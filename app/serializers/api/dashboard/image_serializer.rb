module Api
  module Dashboard
    class ImageSerializer < ::ApplicationSerializer
      attributes :id, :file_url

      def file_url
        Rails.application.routes.url_helpers.rails_blob_path(object.file)
      end
    end
  end
end
