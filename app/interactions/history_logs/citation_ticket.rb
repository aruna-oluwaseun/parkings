module HistoryLogs
  # @example instantiate and execute as
  #   ::HistoryLogs::CitationTicket.new(params).result
  # @param :citation_ticket Object
  # @return [Hash]
  class CitationTicket < ApplicationInteraction
    object :citation_ticket, class: ::Parking::CitationTicket

    def execute
      serialized_violation_report.values.flatten.compact.sort do |a, b|
        a[:created_at] <=> b[:created_at]
      end
    end

    def serialized_violation_report
      ::Api::V1::Parking::CitationTicketLogSerializer.new(citation_ticket).serializable_hash.symbolize_keys
    end
  end
end
