module Api
  module Dashboard
    class CitationTicketsQuery < ::ApplicationQuery
      # @return ActiveRecord::Relation of {Parking::CitationTicket citation ticket model}
      def call
        id, status, violation_type = options[:id], options[:status], options[:violation_type]
        officer_id , parking_lot_id = options[:officer_id], options[:parking_lot_id]

        scope = ::Parking::CitationTicket
                .with_role_condition(options[:user])
                .left_outer_joins({
                  violation:
                    [
                      { vehicle_rule: [:vehicle] },
                      { rule: :lot },
                      { ticket: [:photo_resolution_attachment, :agency] }
                    ]
                })

        sql_query, attr_query = [], []

        if id
          sql_query.push('parking_citation_tickets.id = ?')
          attr_query.push(id)
        end

        if status
          sql_query.push('parking_citation_tickets.status = ?')
          attr_query.push(::Parking::CitationTicket.statuses[status])
        end

        if violation_type
          sql_query.push('parking_rules.name = ?')
          attr_query.push(::Parking::Rule.names[violation_type])
        end

        if officer_id
          sql_query.push('parking_tickets.admin_id = ?')
          attr_query.push(officer_id)
        end

        if parking_lot_id
          sql_query.push('parking_lots.id = ?')
          attr_query.push(parking_lot_id)
        end

        if options.dig(:range, :from)
          from = options.dig(:range, :from).to_date.beginning_of_day
          to = options.dig(:range, :to).blank? ? DateTime::Infinity.new : options.dig(:range, :to).to_date.end_of_day
          scope = scope.where(created_at: from..to)
        end

        scope.where(sql_query.join(' AND '), *attr_query).order('created_at DESC')
      end
    end
  end
end
