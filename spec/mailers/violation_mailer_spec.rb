require 'rails_helper'

describe ViolationMailer, type: :mailer do
  include ApplicationHelper

  let(:user) { create(:user) }
  let(:violation) { create(:parking_violation) }
  let(:mail) { ViolationMailer.commited(user.email, violation) }

  before do
    stub_const(
      'ENV', ENV.to_hash.merge(
        'MAIL_SENDER_NAME' => 'Jun Park',
        'MAIL_FROM' => 'parkingboy@parksmart.com'
      )
    )
  end

  describe '#commited' do
    context 'headers' do
      it 'set headers' do
        expect(mail.subject).to eq(I18n.t('violation_mailer.commited.subject'))
        expect(mail.to).to eq([user.email])
      end
    end

    context 'body' do
      subject { mail.body.encoded }

      it { is_expected.to include "Hi, #{user.email}!" }
      it { is_expected.to include "Parking rule #{violation.rule.description}" }
      it { is_expected.to include "violated at #{violation.created_at.in_time_zone('Eastern Time (US & Canada)')}!" }
      it { is_expected.to include "Car plate detected: #{violation.session.vehicle.plate_number}" }
      it { is_expected.to include "Parking Space detected: #{violation.session.parking_slot&.name}" }
      it { is_expected.to include "Parking Lot Address: #{violation.session.parking_lot.full_address}" }
    end
  end
end
