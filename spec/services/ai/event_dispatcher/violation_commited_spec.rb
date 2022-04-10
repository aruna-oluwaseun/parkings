require 'rails_helper'

RSpec.describe Ai::EventDispatcher, type: :service do
  include ActiveJob::TestHelper

  let(:admin) { create(:admin) }
  let(:agency) { create(:agency, :with_officer, :with_manager) }
  let(:vehicle) { create(:vehicle) }
  let(:parking_lot) { create(:parking_lot, :with_rules, agency: agency) }
  let(:parking_slot) { create(:parking_slot, parking_lot: parking_lot, status: :occupied) }
  let(:parking_session) { create(:parking_session, parking_lot: parking_lot, vehicle: vehicle, parking_slot: parking_slot) }
  let(:payload) { violation_commited_payload(parking_session) }

  before { clear_enqueued_jobs }

  describe 'violation commited' do
    subject do
      perform_enqueued_jobs { described_class.dispatch(payload) }
    end

    it 'creates new violation record' do
      expect { subject }.to change(Parking::Violation, :count).by(1)
    end

    it 'creates new ticket record' do
      expect { subject }.to change(Parking::Ticket, :count).by(1)
    end

    it 'don\'t create violation if rule is not active' do
      parking_lot.rules.find_by(name: 'overlapping').update(status: false)
      expect { subject }.to change(Parking::Ticket, :count).by(1)
    end

    it 'saves images of violation' do
      expect { subject }.to change(Image, :count)
    end

    it 'notifies corresponding parties' do
      message = double(:message)
      allow(message).to receive(:deliver_later)
      expect(ViolationMailer).to receive(:commited).at_least(:once).and_return(message)
      subject
    end

    it 'notifies law enforcement agency manager' do
      subject
      expect(enqueued_emails).to include(agency_manager_email)
    end

    it 'notifies officer' do
      subject
      expect(enqueued_emails).to include(officer_email)
    end

    it 'notifies recipient' do
      subject
      expect(enqueued_emails).to include(recipient_email)
    end
  end

  def enqueued_emails
    ViolationMailer.deliveries.map(&:to).flatten
  end

  def agency_manager_email
    parking_lot.agency.manager&.email
  end

  def officer_email
    overlapping_rule.officer&.email
  end

  def recipient_email
    overlapping_rule.recipients.first&.admin&.email
  end

  def overlapping_rule
    parking_lot.rules.find_by(name: 'overlapping')
  end
end
