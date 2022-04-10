module Api
  module Dashboard
    class CitationTicketsIndexQuery < ::ApplicationQuery
      # @return ActiveRecord::Relation of {Parking::CitationTicket citation ticket model}
      def call
        scope = ::Parking::CitationTicket.with_role_condition(options[:user])
        scope.includes({
          violation:
            [
              { vehicle_rule: [:vehicle] },
              { rule: :lot },
              { ticket: [:photo_resolution_attachment, :agency] }
            ]
        })
      end
    end
  end
end
