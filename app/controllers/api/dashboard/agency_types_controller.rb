module Api
  module Dashboard
    class AgencyTypesController < ::Api::Dashboard::ApplicationController
      api :GET, '/api/dashboard/agency_types', 'List of Agency Types'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer, 'Items per page count, default is 10. Check response headers for total count (key: X-Total)'
      param :page, Integer, 'Items page number'
      param :order, Hash, I18n.t('api.params.order') do
        param :keyword, AgencyType.attribute_names, I18n.t('api.params.keyword'), required: false
        param :direction, %w{asc desc}, I18n.t('api.params.direction'), required: false
      end

      def index
        authorize! ::AgencyType
        scope = paginate ::Api::Dashboard::AgencyTypesQuery.call(params.merge(user: current_user))
        respond_with scope, each_serializer: ::Api::Dashboard::AgencyTypeSerializer
      end

      api :POST, '/api/dashboard/agency_types', 'Create new Agency Type'
      header :Authorization, 'Auth token', required: true
      param :agency_type, Hash do
        param :name, String, required: true
      end

      def create
        authorize! ::AgencyType
        payload = params.fetch(:agency_type, {})
        result = ::AgencyTypes::Create.run(payload)
        respond_with result, serializer: ::Api::Dashboard::AgencyTypeSerializer
      end

      api :PUT, '/api/dashboard/agency_types/:id', 'Update Agency Type'
      header :Authorization, 'Auth token', required: true
      param :id, Integer, 'Agency Type to update ID'
      param :agency_type, Hash do
        param :name, String, required: false
      end

      def update
        agency_type = ::AgencyType.find(params[:id])
        authorize! agency_type
        payload = params.fetch(:agency_type, {}).merge(object: agency_type)
        result = ::AgencyTypes::Update.run(payload)
        respond_with result, serializer: ::Api::Dashboard::AgencyTypeSerializer
      end

      api :GET, '/api/dashboard/agency_types/:id', 'Get Agency Type by ID'
      param :id, Integer, 'Agency Type id', required: true
      header :Authorization, 'Auth token', required: true

      def show
        agency_type = AgencyType.find(params[:id])
        authorize! agency_type
        respond_with agency_type, serializer: ::Api::Dashboard::AgencyTypeSerializer
      end

      api :DELETE, '/api/dashboard/agency_types/:id', 'Delete Agency Type'
      param :id, Integer, 'Agency Type id', required: true
      header :Authorization, 'Auth token', required: true

      def destroy
        agency_type = AgencyType.find(params[:id])
        authorize! agency_type
        result = ::AgencyTypes::Delete.run(object: agency_type)
        respond_with result, serializer: ::Api::Dashboard::AgencyTypeSerializer
      end

      private

      def per_page
        params[:per_page] || 20
      end
    end
  end
end
