module Api
  module V1
    module Parking
      module Violation
        class TicketLogSerializer < ::ApplicationSerializer
          attributes :status, :assigned_to

          def assigned_to
            has_changes = object.event == 'update' && !assignee_log_changes.nil?
            return unless has_changes

            user = admin_name(object.whodunnit)
            old_value = assignee_log_changes.first ? ::Admin.find_by_id(assignee_log_changes.first)&.name : 'No Value'
            new_value = assignee_log_changes.last ? ::Admin.find_by_id(assignee_log_changes.last)&.name : 'No Value'
            attribute = 'Change of Assignee'
            {
              user: user,
              created_at: utc(object.created_at),
              old_value: old_value,
              new_value: new_value,
              attribute: attribute,
              message: I18n.t(
                'logs.transactions.parking_violation.update',
                attribute: attribute,
                from: old_value,
                to: new_value,
                user: user
              )
            }
          end

          def status
            has_changes = object.event == 'update' && status_log_changes.present?
            return unless has_changes

            user = admin_name(object.whodunnit)
            old_value = status_log_changes.first ? I18n.t("activerecord.models.tickets.statuses.#{::Parking::Ticket::STATUSES.keys[status_log_changes.first]}") : 'No value'
            new_value = status_log_changes.last ? I18n.t("activerecord.models.tickets.statuses.#{::Parking::Ticket::STATUSES.keys[status_log_changes.last]}") : 'No value'
            attribute = 'Change of Status'
            {
              user: user,
              created_at: utc(object.created_at),
              old_value: old_value,
              new_value: new_value,
              attribute: attribute,
              message: I18n.t(
                'logs.transactions.parking_violation.update',
                attribute: attribute,
                from: old_value,
                to: new_value,
                user: user
              )
            }
          end

          def object_changes
            @object_changes ||= ::YAML.load(object.object_changes).symbolize_keys
          end

          def status_log_changes
            @status_log_changes ||= object_changes&.dig(:status)
          end

          def assignee_log_changes
            @assignee_log_changes ||= object_changes&.dig(:admin_id)
          end
        end
      end
    end
  end
end
