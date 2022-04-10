module Api
  module V1
    module Parking
      module Violation
        class ViolationLogSerializer < ::ApplicationSerializer
          attributes :status, :assigned_to, :violation_type, :comments

          # @overload create_log
          # This method return logs Parking::Violation is created
          # @return [Hash]
          def create_log
            log = object.logs.where(event: 'create').first

            {
              user: admin_name(log.whodunnit),
              created_at: utc(log.created_at),
              message: I18n.t('logs.transactions.create', entity: 'parking violation', id: object.id, user: admin_name(log.whodunnit))
            }
          end

          # @overload comments
          # This method return logs when a comment is updated for Parking::Violation
          # @return [Array]
          def comments
            PaperTrail::Version.where(
              'meta_data @> ?', {
                record_parent: 'Parking::Violation',
                record_model: 'Comment',
                record_id: object.id
              }.to_json
            ).where(event: ['update']).map do |log|
              object_changes = ::YAML.load(log.object_changes).symbolize_keys.dig(:content)
              return if object_changes.blank?

              attribute = 'Change of Comment'
              old_value = object_changes.first.capitalize
              new_value = object_changes.last.capitalize
              user = admin_name(log.whodunnit)
              {
                user: user,
                created_at: utc(log.created_at),
                old_value: old_value,
                new_value: new_value,
                attribute: attribute,
                message: I18n.t(
                  'logs.transactions.comment.update',
                  from: old_value,
                  to: new_value,
                  user: user,
                  attribute: attribute
                )
              }
            end
          end

          # @overload violation_type
          # This method return logs when Parking::Violation name is updated
          # @return [Hash]
          def violation_type
            serialized_rule_logs.map { |log| log.dig(:violation_type) }.compact
          end

          # @overload status
          # This method return logs when status is updated
          # @return [Hash]
          def status
            serialized_ticket_logs.map { |log| log.dig(:status) }.compact
          end

          # @overload assigned_to
          # This method return logs when Parking::Violation.ticket.admin_id is updated
          # @return [Hash]
          def assigned_to
            serialized_ticket_logs.map { |log| log.dig(:assigned_to) }.compact
          end

          # @overload serialized_ticket_logs
          # This method return logs from Parking::Violation.ticket logs
          # @return [Hash]
          def serialized_ticket_logs
            @serialized_ticket_logs ||= object.ticket.logs.
                                        where(event: 'update').
                                        map { |log| TicketLogSerializer.new(log).serializable_hash }
          end

          # @overload serialized_rule_logs
          # This method return logs from Parking::Rules
          # @return [Hash]
          def serialized_rule_logs
            @serialized_rule_logs ||= object.rule.logs.
                                      where(event: 'update').
                                      map { |log| RuleLogSerializer.new(log).serializable_hash }
          end

          # @overload object_changes
          # This method return update logs changes
          # @return [Hash]
          def object_changes
            changes = object.logs.where(event: 'update').first&.object_changes

            return unless changes.present?

            @object_changes ||= ::YAML.load(changes).symbolize_keys
          end
        end
      end
    end
  end
end
