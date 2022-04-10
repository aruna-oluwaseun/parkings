module Api
  module V1
    class WalletsController < ::Api::V1::ApplicationController
      before_action :authenticate_user!

      api :PUT, '/api/v1/user/wallet', 'Fill user wallet'
      param :gateway_params, Hash, 'Params related to the payment information', required: false do
        param :amount, String, 'Amount to bill'
        param :production, [0, 1], '1 indicate that the payment will be using the real credit cards, so it will create a real charge to the card', required: false
        param :set_credit_card_as_default, [0, 1], '1 indicate that the credit card will be set as default for the acocunt', required: false
        param :digital_wallet_attributes, Hash, 'New credit card', required: false do
          param :encryptionhandler, ['EC_GOOGLE_PAY', 'EC_APPLE_PAY'], 'Credit card number', required: true
          param :devicedata, String, 'String returned by mobile app request', required: true
        end
        param :credit_card_id, String, 'Credit card ID associated to a user (This should be provided if the user wants to pay with a stored credit_card)', required: false
        param :credit_card_attributes, Hash, 'New credit card', required: false do
          param :number, String, 'Credit card number', required: true
          param :cvv, String, 'Credit card cvv ', required: true
          param :holder_name, String, 'Credit card holder name ', required: true
          param :expiration_year, String, 'Credit card expiration year', required: true
          param :expiration_month, String, 'Credit card expiration month ', required: true
          param :should_store, [0, 1], 'Indicate if the provided credit card should be associated to the user account', requried: true
        end
        param :billing_address, Hash do
          param :address1, String, required: true
          param :address2, String, required: false
          param :city, String, required: true
          param :country_code, String, required: true
          param :state_code, String, "It has to be the full name of the state", required: true
          param :postal_code, String, required: true
        end
        param :last_credit_card_digits, String, 'Last 4 digits when using Apple pay', required: false
      end

      def update
        result = ::Wallets::Update.run(params.merge(user: current_user))
        respond_with result.result, serializer: ::Api::V1::WalletRechargePaymentSerializer
      end
    end
  end
end
