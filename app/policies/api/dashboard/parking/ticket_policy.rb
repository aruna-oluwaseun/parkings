module Api
  module Dashboard
    module Parking
      class TicketPolicy < ::ApplicationPolicy
        def update?
          permitted?
        end

        def show?
          permitted?
        end

        private

        def permitted?
          user.admin? || agency_manager? || officer_ticket?
        end

        def agency_manager?
          record.agency.managers.include?(user)
        end

        def officer_ticket?
          record.agency.officers.include?(user)
        end
      end
    end
  end
end
