module Api
  class ApplicationController < ::ApplicationController
    include ::Api::Errors
    include Pagy::Backend

    after_action :add_pagination_headers

    protect_from_forgery with: :null_session
    respond_to :json
    self.responder = ::ApiResponder

    private

    def per_page
      params[:per_page] || Pagy::VARS[:items]
    end

    def page
      params[:page]
    end

    def paginate(scope, **options)
      @pagy, paginated_scope = pagy_array(scope.to_a, options.merge({ items: per_page, page: page}))
      paginated_scope
    end

    def array_serializer
      ActiveModel::Serializer::CollectionSerializer
    end

    private

    # @overload add_pagination_headers
    # This callback adds the pagination headers to response
    # Return [Pagy Object]
    def add_pagination_headers
      pagy_headers_merge(@pagy) if @pagy
    end
  end
end
