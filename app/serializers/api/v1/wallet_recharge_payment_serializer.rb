module Api
  module V1
    class WalletRechargePaymentSerializer < ::ApplicationSerializer
      attributes :id,
                 :amount,
                 :user_id,
                 :status,
                 :payment_method,
                 :payment_gateway,
                 :card_last_four_digits,
                 :reference_number,
                 :created_at,
                 :updated_at
    end
  end
end
