require 'rails_helper'

describe UserMailer, type: :mailer do
  include ApplicationHelper

  let(:vehicle) { create(:vehicle) }
  let(:parking_session) { create(:parking_session, :with_cash_payment, vehicle: vehicle) }
  let(:payment) { parking_session.payments.last }
  let(:mail) do
    UserMailer.payment_receipt({
      user_id: parking_session.user.id,
      session_id: parking_session.id,
      amount: payment.amount,
      payment_date: payment.created_at,
      payment_id: payment.id
    })
  end

  before do
    stub_const(
      'ENV', ENV.to_hash.merge(
        'MAIL_SENDER_NAME' => 'Jun Park',
        'MAIL_FROM' => 'parkingboy@parksmart.com'
      )
    )
  end

  describe '#payment_receipt' do
    context 'headers' do
      it 'set headers' do
        expect(mail.subject).to eq('Park Smart Payment Confirmation')
        expect(mail.to).to eq([parking_session.user.email])
        expect(mail.from).to eq(['parkingboy@parksmart.com'])
      end
    end

    context 'body' do
      subject { mail.body.encoded }

      it { is_expected.to include "Parking Transaction Number: #{parking_session.id}" }
      it { is_expected.to include "Transaction Date: #{formatted_datetime(payment.created_at.to_date)}" }
      it { is_expected.to include 'Status: Completed' }
      it { is_expected.to include "Payment Transaction Number: #{payment.id}" }
    end
  end
end
