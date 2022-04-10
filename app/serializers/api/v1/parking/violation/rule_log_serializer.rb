module Api
  module V1
    module Parking
      module Violation
        class RuleLogSerializer < ::ApplicationSerializer
          attributes :violation_type

          # @overload violation_type
          # This method return logs when Parking::Violation.rule is updated
          # @return [Hash]
          def violation_type
            return if violation_type_changes.blank?

            user = admin_name(object.whodunnit)
            attribute = 'Change of Violation Type'
            old_value = I18n.t("activerecord.models.rules.description.#{::Parking::Rule.names.keys[violation_type_changes.first]}")
            new_value = I18n.t("activerecord.models.rules.description.#{::Parking::Rule.names.keys[violation_type_changes.last]}")
            {
              user: user,
              created_at: utc(object.created_at),
              attribute: attribute,
              old_value: old_value,
              new_value: new_value,
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

          def violation_type_changes
            @status_log_changes ||= object_changes&.dig(:name)
          end
        end
      end
    end
  end
end
