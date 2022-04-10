module Api
  module V1
    module Parking
      class ViolationSerializer < ::ApplicationSerializer
        attributes :id
        has_one :citation_ticket, serializer: ::Api::Dashboard::Parking::CitationTicketSerializer
      end
    end
  end
end
