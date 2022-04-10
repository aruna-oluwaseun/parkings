module Wallets
  class Update < ::ApplicationInteraction
    object :user, class: User

    hash :gateway_params, strip: false, default: {}

    attr_reader :wallet

    set_callback :execute, :before, -> do
      @wallet = user.wallet
    end

    def execute
      cardconnect = PaymentGateway::Cardconnect.new(user, gateway_params)
      response = cardconnect.pay!
      # respstat possible values
      # A - Approved
      # B - Retry
      # C - Declined
      case response.parse['respstat']
      when 'A'
        wallet_recharge_payment = user.wallet_recharge_payments.create(
                                        amount: cardconnect.amount, status: :success,
                                        reference_number: response.parse['retref'],
                                        payment_method: :credit_card, meta_data: response.parse,
                                        card_last_four_digits: cardconnect.card_last_four_digits(response.parse['token']),
                                        payment_gateway: 'cardconnect'
                                      )
        wallet.update(amount: wallet.amount + cardconnect.amount)
        cardconnect.store_credit_card
        WalletMailer.filled(user, wallet_recharge_payment.amount).deliver_later
        wallet_recharge_payment
      when 'B', 'C'
        user.wallet_recharge_payments.create(
              amount: cardconnect.amount,
              status: :failed, payment_method: :credit_card,
              payment_gateway: 'cardconnect',
              meta_data: response.parse,
              card_last_four_digits: cardconnect.card_last_four_digits(response.parse['token'])
            )
        raise ::Payments::StandardError, "Something went wrong on the payment process. Reason: #{response.parse['resptext']}"
      end
    end
  end
end
