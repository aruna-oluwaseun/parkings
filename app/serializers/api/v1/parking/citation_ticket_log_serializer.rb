module Api
  module V1
    module Parking
      class CitationTicketLogSerializer < ::ApplicationSerializer
        attributes :status, :comments

        # @overload status
        # This method return logs when status is updated
        # @return [Hash]
        def status
          object.logs.where(event: ['update']).map do |log|
            object_changes = ::YAML.load(log.object_changes).symbolize_keys.dig(:status)
            return if object_changes.blank?

            user = admin_name(log.whodunnit)
            old_value = I18n.t("activerecord.models.parking/citation_tickets.statuses.#{::Parking::CitationTicket::STATUSES.keys[object_changes.first]}")
            new_value = I18n.t("activerecord.models.parking/citation_tickets.statuses.#{::Parking::CitationTicket::STATUSES.keys[object_changes.last]}")
            attribute = 'Status'
            {
              user: user,
              created_at: utc(log.created_at),
              old_value: old_value,
              new_value: new_value,
              attribute: attribute,
              message: I18n.t('logs.transactions.parking_violation.update',
                attribute: attribute,
                from: old_value,
                to: new_value,
                user: user
              )
            }
          end
        end

        # @overload comments
        # This method return logs when a comment is updated for Parking::Violation
        # @return [Array]
        def comments
          PaperTrail::Version.where(
            'meta_data @> ?', {
              record_parent: 'Parking::CitationTicket',
              record_model: 'Comment',
              record_id: object.id
            }.to_json
          ).where(event: ['update']).map do |log|
            object_changes = ::YAML.load(log.object_changes).symbolize_keys.dig(:content)
            return if object_changes.blank?

            attribute = 'Comment'
            user = admin_name(log.whodunnit)
            old_value = object_changes.first.capitalize
            new_value = object_changes.last.capitalize
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

        # @overload serialized_violation_log
        # This method returns Parking::CitationTicket attributes previous and current values
        # @return [Hash]
        def object_changes
          changes = object.logs.where(event: 'update').first&.object_changes

          return nil unless changes.present?

          @object_changes ||= ::YAML.load(changes).symbolize_keys
        end
      end
    end
  end
end
