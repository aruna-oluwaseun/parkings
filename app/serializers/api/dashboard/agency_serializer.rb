module Api
  module Dashboard
    class AgencySerializer < ::ApplicationSerializer
      attributes :id, :name, :location, :email, :phone, :manager, :officers, :status, :can_deleted, :parking_lots, :agency_type

      def manager
        if user = object.manager
          {
            id: user.id,
            username: user.username,
            name: user.name
          }
        end
      end

      def officers
        ActiveModel::Serializer::CollectionSerializer.new(
          object.officers,
          serializer: ::Api::Dashboard::ThinAdminSerializer
        )
      end

      def parking_lots
        object.parking_lots.map do |parking_lot|
          {
            id: parking_lot.id,
            name: parking_lot.name
          }
        end
      end

      def location
        if location = object.location
          ::LocationSerializer.new(location)
        end
      end

      def can_deleted
        object.can_deleted?
      end

      def agency_type
        ::Api::Dashboard::AgencyTypeSerializer.new(object.agency_type) if object.agency_type
      end

    end
  end
end
