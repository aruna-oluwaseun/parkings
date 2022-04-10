module DropdownFields
  module Mobile
    class NotificationTypesList < ::DropdownFields::Base
      USER_NOTIFICATION_TEMPLATES = I18n.t('activerecord.models.user/notification.templates').with_indifferent_access.freeze

      def execute
        template_names.each_with_object([]) do |template_name, notification_types|
           notification_types << { value: template_name, label: USER_NOTIFICATION_TEMPLATES["#{template_name}_title"] }
        end
      end

      def value_attr
        :value
      end

      def label_attr
        :label
      end

      private

      def template_names
        %i[
          car_entrance
          car_parked
          car_exit
          car_left
          park_will_to_expire
          park_expired
          park_extended
          wallet_filled
          success_payment
          payment_failure
          violation_commited
          violation_canceled
          citation_created
          citation_settled
          citation_canceled
          citation_sent_to_court
        ]
      end
    end
  end
end
