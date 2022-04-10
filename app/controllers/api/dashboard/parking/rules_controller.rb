module Api
  module Dashboard
    class Parking::RulesController < ::Api::Dashboard::ApplicationController
      before_action :set_parking_lot, only: [:index, :update]
      before_action :set_parking_rules, only: [:index]

      api :GET, '/api/dashboard/parking_rules', 'Parking rules list'
      header :Authorization, 'Auth token', required: true
      param :per_page, Integer,
            'Items per page count, default is 10. Check response headers for total count (key: F)',
            required: false
      param :page, Integer, 'Items page number', required: false
      param :parking_lot_id, Integer, 'Parking lot ID related to the rules', required: false

      def index
        respond_with @rules, each_serializer: ::Api::Dashboard::Parking::RuleSerializer
      end

      api :PUT, '/api/dashboard/parking_rules', 'Update parking rule'
      api :PATCH, '/api/dashboard/parking_rules', 'Update parking rule'
      header :Authorization, 'Auth token', required: true
      param :parking_lot_id, Integer, 'Parking lot ID related to the rules', required: true
      param :agency_id, Integer, 'Agency ID related to the parking lot', required: true
      param :parking_rules, Array, of: Hash, required: true do
        param :name, Integer
        param :status, [true, false, 1, 0]
        param :description, String
        param :recipient_ids, Array, of: Hash
        param :admin_id, Integer, "Parking lot's agency officer"
      end

      def update
        return parking_lot_not_found! if @parking_lot.blank? # Ensure we are updating only the rules of one parking lot

        rules = params[:parking_rules]&.map do |parking_rule|
          rule = ::Parking::Rule.find(parking_rule['id'])
          authorize! rule
          parking_rule.merge(object: rule)
        end

        result = ::Parking::Rules::UpdateMultiple.run({
         rules: rules,
         lot_id: params[:parking_lot_id],
         agency_id: params[:agency_id]
        })

        respond_with result, each_serializer: ::Api::Dashboard::Parking::RuleSerializer
      end

      private

      def set_parking_lot
        @parking_lot = ParkingLot.find_by_id(params[:parking_lot_id])
      end

      def set_parking_rules
        @rules = ::Parking::Rule.names.keys.sort.map do |name|
          rule = ::Parking::Rule.find_or_initialize_by(
            name: name,
            lot: @parking_lot
          )

          rule.save if @parking_lot
          rule
        end
      end
    end
  end
end
