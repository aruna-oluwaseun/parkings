
# frozen_string_literal: true
# Test Documentation: https://developer.cardconnect.com/guides/cardpointe-gateway
module PaymentGateway
  class Cardconnect < Base

    DATA = {
      test: {
        site: ENV['CARDCONNECT_SITE_TEST'],
        merchant_id: ENV['CARDCONNECT_MERCHANT_ID_TEST'],
        user: ENV['CARDCONNECT_USER_TEST'],
        password: ENV['CARDCONNECT_PASSWORD_TEST']
      },
      production: {
        site: ENV['CARDCONNECT_SITE_PRODUCTION'],
        merchant_id: ENV['CARDCONNECT_MERCHANT_ID_PRODUCTION'],
        user: ENV['CARDCONNECT_USER_PRODUCTION'],
        password: ENV['CARDCONNECT_PASSWORD_PRODUCTION']
      }
    }

    def rest_auth_url
      "https://#{DATA[env_key][:site]}.cardconnect.com/cardconnect/rest/auth"
    end

    def tokenize_url
      "https://#{DATA[env_key][:site]}.cardconnect.com/cardsecure/api/v1/ccn/tokenize"
    end

    def env_key
      @params[:production].to_s == '1' ? :production : :test
    end

    def charge_customer
      @token = tokenize_card

      json_params = using_digital_wallet? ? digital_wallet_charge_params : charge_params
      response = HTTP.basic_auth(user: DATA[env_key][:user], pass: DATA[env_key][:password]).post(rest_auth_url, { json: json_params })
    end

    def card_last_four_digits(token)
      if using_digital_wallet?
         @params[:last_credit_card_digits]
      else
        token.last(4)
      end
    end

    private

    def tokenize_card
      # Search or accept a new card
      if using_digital_wallet?
        options = {
          json: {
            encryptionhandler: @params.dig(:digital_wallet_attributes, :encryptionhandler),
            devicedata: @params.dig(:digital_wallet_attributes, :devicedata)
          }
        }
      else
        options = {
          json: {
            account: credit_card['number']
          }
        }
      end
      response = HTTP.post(tokenize_url, options)
      error_code = response.parse.dig('errorcode')
      if error_code.to_s == '0'
        response.parse.dig('token')
      else
        write_logs(response.parse)
        raise ::Payments::StandardError, 'Something went wrong during the token request'
      end
    end

    def digital_wallet_charge_params
      {
        "merchid": DATA[env_key][:merchant_id],
        "account": @token,
        "amount": amount.to_s,
        "currency": "USD",
        "email": customer.email,
        "capture": "y",
        "receipt": "y"
      }
    end

    def charge_params
      {
        "merchid": DATA[env_key][:merchant_id],
        "account": @token,
        "expiry": "#{credit_card[:expiration_month].to_s.rjust(2, '0')}#{credit_card[:expiration_year]}",
        "cvv2":  @params[:credit_card_attributes][:cvv],
        "amount": amount.to_s,
        "currency": "USD",
        "name": credit_card[:holder_name],
        "email": customer.email,
        "capture": "y",
        "receipt": "y"
      }.merge(charge_billing_address_params)
    end

    def charge_billing_address_params
      return {} unless billing_address_params

      {
        "address": billing_address_params[:address1],
        "address2": billing_address_params[:address2],
        "city": billing_address_params[:city],
        "country": billing_address_params[:country_code],
        "region": billing_address_params[:state_code],
        "postal": billing_address_params[:postal_code]
      }
    end

    def billing_address_params
      @params[:billing_address]
    end

    def using_digital_wallet?
      @params[:digital_wallet_attributes].present?
    end

    def payment_method
      if using_digital_wallet? && @params[:last_credit_card_digits]
        "#{@params.dig(:digital_wallet_attributes, :encryptionhandler)}_CC"
      elsif using_digital_wallet?
        @params.dig(:digital_wallet_attributes, :encryptionhandler)
      else
        'PAY_WITH_CC'
      end
    end
  end
end

