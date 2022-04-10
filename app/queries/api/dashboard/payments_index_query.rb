module Api
  module Dashboard
    class PaymentsIndexQuery < ApplicationQuery

      def call
        query, status, plate_number, first_name = options[:query], options[:status], options[:plate_number], options[:first_name]
        amount, name, created_at, id, order = options[:amount], options[:name], options[:created_at], options[:id], options[:order]
        scope = Payment.with_role_condition(options[:user])
        scope = scope.where(status: status) if status.present?
        scope = scope.where(amount: amount) if amount.present?
        scope =  scope.where(created_at: created_at ) if created_at.present?
        scope = scope.where(id: id) if id.present?
        scope = scope.joins(:parking_session, :user).where(users: { first_name: first_name }) if first_name.present?
        scope = scope.joins(:parking_session, :vehicle).where(vehicles: { plate_number: plate_number }) if plate_number.present?
        scope = scope.joins(:parking_session, :parking_lot).where(parking_lots: { name: name }) if name.present?
        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          scope = scope.order(Arel.sql("#{keyword} #{direction}"))
        end
        scope.eager_load(:parking_session)
      end
    end
  end
end
