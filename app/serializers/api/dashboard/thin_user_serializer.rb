module Api
  module Dashboard
    class ThinUserSerializer < ::ApplicationSerializer

      attributes :email, :first_name, :last_name, :phone, :created_at

      def first_name
        object.first_name&.upcase
      end

    end
  end
end
