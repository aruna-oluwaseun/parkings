module Api
  module Dashboard
    class NotificationsController < ::Api::Dashboard::ApplicationController
      skip_before_action :authenticate_admin!
      before_action :find_notification, only: [:show, :update]

      api :GET, '/api/dashboard/notifications', 'Get a list of notifications'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page', required: false
      param :ids, Array, of: Integer
      param :type, Array, of: User::Notification.templates.keys
      param :status, Array, of: User::Notification.statuses.keys
      param :vehicle_id, Array, of: Integer

      def index
        scope = paginate notifications_scope
        respond_with scope, each_serializer: serializer
      end

      api :GET, '/api/dashboard/notifications/:id', 'Get notification'
      param :id, Integer, 'Notification id', required: true
      header :Authorization, 'Auth token from Superuser#sign_in', required: true

      def show
        respond_with @notification, serializer: serializer
      end

      api :PUT, '/api/dashboard/notifications/:id', 'Mark notification as read'
      param :id, Integer, 'Notification id', required: true
      param :text, String, 'Body of the Notification', required: true
      header :Authorization, 'Auth token from Superuser#sign_in', required: true

      def update
        @notification.update(params.permit(:text, :status))
        respond_with @notification, serializer: ::Api::Dashboard::NotificationSerializer
      end

      def find_notification
        @notification = notifications_scope.find(params[:id])
        authorize! @notification
      end

      api :GET, '/api/dashboard/notifications/types', 'Get all possible notification types'
      header :Authorization, 'Auth token from users#sign_in', required: true

      def types
        respond_with(User::Notification.templates.each_with_object({}) do |(template, _), memo|
          memo[template] = t("activerecord.models.user/notification.templates.#{template}_title")
        end)
      end

      private

      def notifications_scope(options={})
        ::Api::Dashboard::NotificationsQuery.call(params.merge(user: current_user).merge(options))
      end

      def serializer
        ::Api::Dashboard::NotificationSerializer
      end

    end
  end
end
