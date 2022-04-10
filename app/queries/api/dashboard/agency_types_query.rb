# frozen_string_literal: true

module Api
  module Dashboard
    class AgencyTypesQuery < ApplicationQuery

      def call
        scope = AgencyType.all

        if options[:order]
          keyword, direction = options[:order][:keyword], options[:order][:direction]
          return scope.order(Arel.sql("#{keyword} #{direction}"))
        end
        scope
      end
    end
  end
end
