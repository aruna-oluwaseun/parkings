module Api
  module V1
    class VehiclesQuery < ::ApplicationQuery
      def call
        plate_number, first_name, last_name, manufacturer_id, status, created_at,
        user_associated =  options[:plate_number], options[:first_name], options[:last_name],
        options[:manufacturer_id], options[:status],options[:created_at], options[:user_associated]
        scope = ::Vehicle.all
        scope =  scope.where(status: status ) if status.present?
        scope =  scope.where(created_at: created_at ) if created_at.present?
        scope =  scope.where(plate_number: plate_number ) if plate_number.present?
        scope =  scope.joins(:user).where(users: { first_name: first_name }) if first_name.present?
        scope =  scope.joins(:user).where(users: { last_name: last_name }) if last_name.present?
        scope =  scope.joins(:manufacturer).where(manufacturers: { id: manufacturer_id }) if manufacturer_id.present?

        if user_associated.present?
          if user_associated.to_s == '1'
            scope = scope.where.not(user_id: nil)
          else
            scope = scope.where(user_id: nil)
          end
        end
        scope
      end
    end
  end
end
