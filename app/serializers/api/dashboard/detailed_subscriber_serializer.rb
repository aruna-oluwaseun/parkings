module Api
  module Dashboard
    class DetailedSubscriberSerializer < ::Api::Dashboard::SubscriberSerializer
      attributes :phone, :confirmed_at, :status, :created_at, :updated_at, :is_dev, :vehicles_list

      def confirmed_at
        utc(object.confirmed_at)
      end

      def vehicles_list
        ActiveModel::Serializer::CollectionSerializer.new(object.vehicles, serializer: Api::Dashboard::ThinVehicleSerializer)
      end
    end
  end
end
