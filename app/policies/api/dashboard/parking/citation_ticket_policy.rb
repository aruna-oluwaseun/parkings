module Api
  module Dashboard
    module Parking
      class CitationTicketPolicy < ApplicationPolicy
        def create?
          permission.create? && (user.manager? || agency_manager? || officer_citation_ticket?)
        end

        def show?
          (user.admin? || agency_manager_ticket? || officer_citation_ticket?) && permission.read?
        end

        def update?
          (user.admin? || agency_manager_ticket? || officer_citation_ticket?) && permission.update?
        end

        private

        def agency_manager_ticket?
          ::Parking::CitationTicket.joins(violation: { ticket: { agency: :managers } })
                                   .where(admins: { id: user.id }).exists? if user.manager?
        end

        def officer_citation_ticket?
          ::Parking::CitationTicket.joins(violation: { ticket: { agency: :officers } })
                                   .where(admins: { id: user.id }).exists? if user.officer?
        end
      end
    end
  end
end