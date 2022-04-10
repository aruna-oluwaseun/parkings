module Api
  module Dashboard
    class UsersController < ::Api::Dashboard::ApplicationController
      api :GET, '/api/dashboard/users', 'List of Users/Subscribers'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false
      param :query, Hash, 'Hash query to filter Users/Subscribers' do
        param :users, Hash, 'Filter by' do
          param :first_name, String, 'User/Subscriber first name', required: false
          param :last_name, String, 'User/Subscriber last name', required: false
          param :email, String, 'User/Subscriber email', required: false
        end
      end
      param :range, Hash, 'Date Range (calculated within the selected range)' do
        param :from, Integer, 'From date in timestamp (numeric) format', required: true
        param :to, Integer, 'To date in timestamp (numeric) format', required: true
      end
      param :order, Hash, 'Hash order' do
        param :keyword, ['id', 'first_name', 'last_name', 'email', 'created_at'], "Order keyword", required: false
        param :direction, ['asc', 'desc'], "Order Direction", required: false
      end

      def index
        authorize!
        scope = paginate ::Api::Dashboard::UsersQuery.call(params.merge(current_user: current_user))
        respond_with paginate(scope), each_serializer: ::Api::Dashboard::SubscriberSerializer
      end

      api :GET, '/api/dashboard/users/:id', 'Fetch User/Subscriber details'
      param :id, Integer, required: true
      header :Authorization, 'Auth token', required: true

      def show
        user = User.find(params[:id])
        authorize! user
        respond_with user, serializer: ::Api::Dashboard::DetailedSubscriberSerializer
      end

      api :PUT, '/api/dashboard/users/:id', 'Update User/Subscriber (specify only fields we want to update)'
      param :id, Integer, required: true
      header :Authorization, 'Auth token', required: true
      param :user, Hash, 'User/Subscriber' do
        param :is_dev, [true, false], required: false
        param :status, User.statuses.keys, required: false
      end

      def update
        user = User.find(params[:id])
        authorize! user
        payload = params.fetch(:user, {}).merge(user: user, current_user: current_user)
        result = ::Users::Update.run(payload)
        respond_with result, serializer: ::Api::Dashboard::DetailedSubscriberSerializer
      end

      private

      def per_page
        params[:per_page] || 20
      end
    end
  end
end
