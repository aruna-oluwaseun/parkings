module Api
  module Dashboard
    class VehiclesQuery < ::ApplicationQuery
      def call
        plate_number, first_name, last_name  =  options[:plate_number], options[:first_name], options[:last_name]

        manufacturer_id, status, created_at, order = options[:manufacturer_id], options[:status], options[:created_at], options[:order]

        scope = Vehicle.with_role_condition(options[:user])

        scope =  scope.where(status: status ) if status.present?
        scope =  scope.where(created_at: created_at ) if created_at.present?
        scope =  scope.where(plate_number: plate_number ) if plate_number.present?
        scope =  scope.joins(:user).where(users: { first_name: first_name }) if first_name.present?
        scope =  scope.joins(:user).where(users: { last_name: last_name }) if last_name.present?
        scope =  scope.joins(:manufacturer).where(manufacturers: { id: manufacturer_id }) if manufacturer_id.present?

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.joins(:manufacturer).order(Arel.sql("#{keyword} #{direction}"))
        end
        scope
      end
    end
  end
end
