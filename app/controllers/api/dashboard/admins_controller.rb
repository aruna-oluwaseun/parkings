module Api
  module Dashboard
    class AdminsController < ::Api::Dashboard::ApplicationController
      wrap_parameters :admin, include: Admin.attribute_names + [:password]

      attr_accessor :role

      before_action :set_role, only: [:create, :update]

      api :GET, '/api/dashboard/admins', 'Fetch paginated user list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false
      param :role_id, Integer, required: false
      param :role_names, String, 'Search by role names'
      param :status, Admin.statuses.keys, required: false
      param :query, String, 'Query (can be substring of username, email or name)', required: false

      def index
        scope = paginate Api::Dashboard::AdminsQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: ::Api::Dashboard::UserSerializer
      end

      api :GET, '/api/dashboard/admins/search', 'Search for users'
      header :Authorization, 'Auth token'
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)'
      param :page, Integer, 'Items page number'
      param :role_id, Integer
      param :role_names, String, 'Search by role names'
      param :status, Admin.statuses.keys
      param :subject_type, [Agency.name, ParkingLot.name]
      param :subject_id, Integer, 'agency or parking lot id'
      param :query, String, 'Query (can be substring of username, email or name)'

      def search
        scope = paginate Api::Dashboard::AdminsSearchQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: ::Api::Dashboard::UserSerializer
      end

      api :POST, '/api/dashboard/admins', 'Create new dashboard user'
      header :Authorization, 'Auth token', required: true
      param :admin, Hash do
        param :email, String, required: true
        param :status, Admin.statuses.keys, required: true
        param :username, String, required: true
        param :name, String, required: true
        param :phone, String, required: false
        param :avatar, String, 'File or base64', required: true
      end
      param :role_type, String, required: true
      param :parking_lot_id, String, required: false
      param :agency_id, String, required: false

      def create
        authorize! role, with: AdminPolicy
        result = ::Admins::Create.run(payload)
        respond_with result, serializer: ::Api::Dashboard::DetailedUserSerializer
      end

      api :GET, '/api/dashboard/admins/me', 'Get current user'
      header :Authorization, 'Auth token', required: true

      def me
        respond_with current_user, serializer: ::Api::Dashboard::DetailedUserSerializer
      end

      api :PUT, '/api/dashboard/admins/me', 'Update current user dashboard'
      header :Authorization, 'Auth token', required: true
      param :admin, Hash do
        param :email, String, required: false
        param :username, String, required: false
        param :name, String, required: false
        param :phone, String, required: false
        param :avatar, String, 'File or base64', required: false
        param :delete_avatar, [true, false], 'Indicate if the avatar image should be destroyed', required: false
        param :old_password, String, "Should be blank, if user don't want to change his current password", required: false
        param :password, String, "Should be blank, if user don't want to change it", required: false
      end

      def update_me
        payload = params.fetch(:admin, {}).merge(current_user: current_user)
        result = ::Admins::UpdateCurrentUser.run(payload)
        respond_with result, serializer: ::Api::Dashboard::DetailedUserSerializer
      end

      api :PUT, '/api/dashboard/admins/:id', 'Update dashboard user'
      param :id, Integer, 'User id', required: true
      header :Authorization, 'Auth token', required: true
      param :role_type, String, required: true
      param :parking_lot_id, String, required: false
      param :agency_id, String, required: false
      param :admin, Hash do
        param :email, String, required: false
        param :status, Admin.statuses.keys, required: false
        param :username, String, required: false
        param :name, String, required: false
        param :phone, String, required: false
        param :avatar, String, 'File or base64', required: false
        param :role_id, Integer, required: false
        param :delete_avatar, [true, false], 'Indicate if the avatar image should be destroyed', required: false
        param :password, String, "Should be blank, if user don't want to change it", required: false
      end

      def update
        user = Admin.find(params[:id])
        authorize! role, with: AdminPolicy, to: :create?
        authorize! user
        result = ::Admins::Update.run(payload.merge!(user: user))
        respond_with result, serializer: ::Api::Dashboard::DetailedUserSerializer
      end

      api :GET, "/api/dashboard/admins/:id", 'Get user by ID'
      param :id, Integer, 'User id', required: true
      header :Authorization, 'Auth token', required: true

      def show
        user = Admin.find(params[:id])
        authorize! user
        respond_with user, serializer: ::Api::Dashboard::DetailedUserSerializer
      end

      api :POST, '/api/dashboard/admins/check_password', 'Check current admin password'
      param :admin, Hash do
        param :password, String, 'Current admin password', required: true
      end
      header :Authorization, 'Auth token', required: true

      def check_password
        result = current_user.valid_password?(params.dig(:admin, :password))
        render json: { result: result }
      end

      private

      def payload
        params.fetch(:admin, {}).merge(
          current_user: current_user,
          role_type: params[:role_type],
          parking_lot_ids: params[:parking_lot_ids],
          agency_id: params[:agency_id]
        )
      end

      def per_page
        params[:per_page] || 20
      end

      def set_role
        if params[:role_type]
          name = ::Admins::Create::ROLE_MAPPINGS[params[:role_type].to_sym]
          @role = Role.find_by(name: name)
          role_not_found! unless role.present?
        else
          role_not_found!
        end
      end
    end
  end
end
