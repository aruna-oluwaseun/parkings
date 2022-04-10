module Api
  module Dashboard
    class ParkingViolationsQuery < ::ApplicationQuery
      def call
        ticket_id, ticket_status, violation_type = options[:ticket_id], options[:ticket_status], options[:violation_type]
        agency_id, officer_id  = options[:agency_id], options[:officer_id]
        parking_lot_id = options[:parking_lot_id]
        query, order = options[:query], options[:order]

        scope = ::Parking::Violation
                 .with_role_condition(options[:user])
                 .joins(ticket: { agency: :admins }, rule: :lot)

        sql_query, attr_query = [], []

        if query.present?
          sql_query = []
          attr_query = []
          %w(parking_tickets parking_rules parking_lots agencies).each do |model_name|
            if query[model_name.to_sym].present?
              query[model_name.to_sym].each do |attr, value|
                sql_query.push("#{model_name}.#{attr} ILIKE ?")
                attr_query.push("%#{value}%")
              end
            end
          end
        end

        if ticket_id
          sql_query.push('parking_tickets.id = ?')
          attr_query.push(ticket_id)
        end

        if ticket_status
          sql_query.push('parking_tickets.status = ?')
          attr_query.push(::Parking::Ticket.statuses[ticket_status])
        end

        if violation_type
          sql_query.push('parking_rules.name = ?')
          attr_query.push(::Parking::Rule.names[violation_type])
        end

        if agency_id
          sql_query.push('agencies.id = ?')
          attr_query.push(agency_id)
        end

        if options.dig(:range, :from)
          from = options.dig(:range, :from).to_date.beginning_of_day
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
          scope = scope.where(created_at: from..to)
        end

        scope = scope.includes({ rule: :lot }, { ticket: :agency }).where(sql_query.join(' AND '), *attr_query)

        if order.present?
          keyword, direction = order[:keyword], order[:direction]
          scope = scope.select("parking_violations.*, parking_rules.name, parking_tickets.id, parking_tickets.status, parking_lots.name, agencies.name").order(Arel.sql("#{keyword} #{direction}")).distinct if keyword != "officers.name" and keyword != "agencies.name"
          scope = order_result(scope, keyword, direction)
        else
          scope = scope.order(Arel.sql("parking_violations.created_at desc")).distinct
        end
      end

      private
      def order_result(scope, keyword, direction)
        if keyword == 'officers.name' && direction == 'asc'
          scope = scope.sort_by { |t| [t&.ticket&.admin&.name? ? 1 : 0, t&.ticket&.admin&.name] }
        elsif keyword == 'officers.name' && direction == 'desc'
          scope = scope.sort_by { |t| [t&.ticket&.admin&.name? ? 1 : 0, t&.ticket&.admin&.name] }.reverse
        elsif keyword == 'agencies.name' && direction == 'asc'
          scope = scope.sort_by { |t| [t&.ticket&.agency&.name? ? 1 : 0, t&.ticket&.agency&.name] }
        elsif keyword == 'agencies.name' && direction == 'desc'
          scope = scope.sort_by { |t| [t&.ticket&.agency&.name? ? 1 : 0, t&.ticket&.agency&.name] }.reverse
        end
        scope
      end
    end
  end
end
