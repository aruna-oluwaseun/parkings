module Api
  module Dashboard
    module Parking
      class ViolationPolicy < ApplicationPolicy
        def index?
          permission.read?
        end

        def show?
          (user.admin? || town_manager? || agency_manager? || officer_violation?) && permission.read?
        end

        def update?
          (user.admin? || agency_manager? || officer_violation? || parking_operator?) && permission.update?
        end

        private

        def agency_manager?
          ::Parking::Violation.joins(ticket: { agency: :managers }).where(admins: { id: user.id }).exists? if user.manager?
        end

        def officer_violation?
          ::Parking::Violation.joins(ticket: { agency: :officers }).where(admins: { id: user.id }).exists? if user.officer?
        end
      end
    end
  end
end
