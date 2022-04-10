module Api
  module Dashboard
    class DropdownsController < ApplicationController
      DROPDOWN_CLASS_LIST = %w{
        agency_officers_list
        categories_place
        country_code
        manufacturers_list
        parking_lot_list
        parking_lot_parking_admins_filter
        parking_lot_town_managers_filter
        parking_rule-agencies_list
        parking_rule-recipient
        parking_session_kiosk_ids_list
        parking_session_statuses_list
        payment_methods_list
        role_id
        role_type
        role_names_filter
        tickets_agencies_list
        tickets_officers_filter
        tickets_statuses_field
        tickets_types_field
        admins_by_role-manager
        admins_by_role-officer
        admins_by_role-parking_admin
        admins_by_role-town_manager
        agency_list
        agency_type
        parking_lots_without_agency_list
      }.freeze

      DROPDOWN_CLASS_LIST.each do |class_string|
        api :GET, "/api/dashboard/dropdowns/#{class_string}", I18n.t("doc.dropdowns.dashboard.#{class_string}")
        header :Authorization, I18n.t('doc.auth.token'), required: true
      end

      def show
        params[:current_user] = current_user
        unless DROPDOWN_CLASS_LIST.include?(params[:dropdown_class])
          return render json: { error: I18n.t('api.errors.param_not_permitted') }, status: 422
        end

        respond_with dropdown_class.new(params).search
      end

      private

      def dropdown_class
        "dropdown_fields/dashboard/#{params[:dropdown_class].gsub('-','/')}".classify.constantize
      end
    end
  end
end
