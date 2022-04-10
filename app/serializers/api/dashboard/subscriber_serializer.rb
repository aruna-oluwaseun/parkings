module Api
  module Dashboard
    class SubscriberSerializer < ::ApplicationSerializer
      attributes :id, :first_name, :last_name, :email, :vehicles_owned

      def vehicles_owned
        object.vehicles.size
      end
    end
  end
end
