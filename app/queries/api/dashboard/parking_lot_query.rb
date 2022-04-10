module Api
  module Dashboard
    class ParkingLotQuery < ::ApplicationQuery

      def call
        user, id, query, status, town_managers = options[:user], options[:id], options[:query], options[:status], options[:town_managers]
        parking_admins, available_cameras, order =  options[:parking_admins], options[:available_cameras], options[:order]
        scope = user.available_parking_lots.left_outer_joins(:cameras)
        return [] if scope.blank?

        scope = scope.where(id: id) if id.present?

        if query.present?
          sql_query = []
          attr_query = []
          %w(parking_lots locations).each do |model_name|
            if query[model_name.to_sym].present?
              query[model_name.to_sym].each do |attr, value|
                sql_query.push("#{model_name}.#{attr} ilike ?")
                attr_query.push("%#{value}%")
              end
            end
          end

          scope = scope.joins(:location).where(sql_query.join(' AND '), *attr_query)
        end

        scope = scope.where(status: status) if status.present?
        scope = scope.group("parking_lots.id").having("count(cameras.id) = ? ", available_cameras) if available_cameras.present?
        scope = scope.joins(:admins).where(admins: { id: town_managers }) if town_managers.present?
        scope = scope.joins(:admins).where(admins: { id: parking_admins }) if parking_admins.present?

        scope = ParkingLot.where(id: scope.select('parking_lots.id').uniq).includes(:vehicle_rules, :setting, :location)

        if order.present?
          keyword, direction = options[:order][:keyword], options[:order][:direction]

          if keyword == 'available_cameras'
            scope = scope.group("parking_lots.id").order(Arel.sql("count(cameras.id) #{direction}"))
          elsif keyword == 'full_address'
            scope.joins(:location).order(Arel.sql("locations.full_address #{direction}"))
          elsif keyword == 'town_manager'
            scope.joins(:admin).where(admins: { id: town_managers }).order(Arel.sql("town_managers.name #{direction}"))
          elsif keyword == 'parking_admin'
            scope.joins(:admin).where(admins: { id: parking_admins }).order(Arel.sql("parking_admins.name #{direction}")) if parking_admins.present?
          else
            scope = scope.order(Arel.sql("#{keyword} #{direction}")) if keyword.present? && direction.present?
          end
        else
          scope = scope.order(Arel.sql("parking_lots.created_at desc"))
        end

        scope
      end
    end
  end
end
