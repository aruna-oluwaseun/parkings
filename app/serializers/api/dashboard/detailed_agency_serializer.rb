module Api
  module Dashboard
    class DetailedAgencySerializer < AgencySerializer
      attributes :avatar

      def avatar
        if object.avatar.attached?
          url = object.avatar_thumbnail
          url_for(url) unless url.nil?
        end
      end
    end
  end
end
