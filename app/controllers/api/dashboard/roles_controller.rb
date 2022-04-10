module Api
  module Dashboard
    class RolesController < ApplicationController
      api :GET, '/api/dashboard/roles', 'Roles list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)', required: false
      param :page, Integer, 'Items page number', required: false
      param :order, Hash, 'Hash order' do
        param :keyword, ['id', 'name'], 'Sort by attribute', required: false
        param :direction, ['asc', 'desc'], 'Order Direction', required: false
      end

      def index
        authorize!
        scope = paginate ::Api::Dashboard::RoleQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: RoleSerializer
      end

      api :GET, '/api/dashboard/permissions/permissions_available', 'Permissions available in the app'
      header :Authorization, 'Auth token', required: true

      def permissions
        respond_with ::Role::Permission.permission_available
      end

      api :POST, '/api/dashboard/roles', 'Create a new role'
      header :Authorization, 'Auth token', required: true
      role_params_documentation = Proc.new {
        param :role, Hash, required: true do
          param :name, String, 'Role name', required: true
          param :permissions, Array, of: Hash do
            param :name, ::Role::Permission::PERMISSIONS_AVAILABLE, 'Permission name', required: true
            param :record_create, [true, false], 'Create permission', required: false
            param :record_read, [true, false], 'Read permission', required: false
            param :record_update, [true, false], 'Update permission', required: false
            param :record_delete, [true, false], 'Delete permission', required: false
            param :attrs, Array, of: Hash do
              param :name, String, 'Attribute name', required: true
              param :attr_read, [true, false], 'Read attribute permission', required: false
              param :attr_update, [true, false], 'Read attribute permission', required: false
            end
          end
        end
      }
      role_params_documentation

      def create
        authorize! Role
        payload = params.fetch(:role, {})
        result = Roles::Create.run(payload)
        respond_with result, serializer: RoleSerializer
      end

      api :GET, '/api/dashboard/roles/:id', 'Role details'
      header :Authorization, 'Auth token', required: true

      def show
        role = Role.find(params[:id])
        authorize! role
        respond_with role, serializer: RoleSerializer
      end

      api :PUT, '/api/dashboard/roles/:id', 'Update role (always include permissions list)'
      header :Authorization, 'Auth token', required: true
      role_params_documentation

      def update
        role = Role.find(params[:id])
        authorize! role
        payload = params.fetch(:role, {}).merge(role: role)
        result = Roles::Update.run(payload)
        respond_with result, serializer: RoleSerializer
      end

      api :DELETE, '/api/dashboard/roles/:id', 'Delete role'
      param :id, Integer, 'Role id', required: true
      header :Authorization, 'Auth token from users#sign_in', required: true

      def destroy
        role = Role.find(params[:id])
        authorize! role
        result = Roles::Delete.run(object: role)
        result = result.object unless result.errors.any?
        respond_with result, serializer: RoleSerializer
      end
    end
  end
end
