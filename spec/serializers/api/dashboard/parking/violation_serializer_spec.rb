
require 'rails_helper'

RSpec.describe 'Parking violation serializers', type: :serializer do
  let!(:ticket) { create :parking_ticket, violation: parking_violation }
  let!(:parking_violation) { create :parking_violation }

  subject do
    serializer = described_class.new(parking_violation)
    serialization = ActiveModelSerializers::Adapter.create(serializer)
    JSON.parse(serialization.to_json)
  end

  describe Api::Dashboard::Parking::ViolationSerializer do
    let(:expected_result) do
      {
        id: parking_violation.id,
        parking_ticket_id: ticket.id,
        status: kind_of(String),
        created_at: kind_of(Integer),
        violation_type: kind_of(String),
        parking_lot: {
          id: kind_of(Integer),
          name: kind_of(String)
        },
        agency: {
          id: kind_of(Integer),
          name: kind_of(String)
        },
        officer: {
          id: kind_of(Integer),
          name: kind_of(String),
          email: kind_of(String)
        },
        citation_ticket_id: anything
      }.deep_stringify_keys
    end

    it 'should returns correct result' do
      expect(subject).to match(expected_result)
    end
  end

  describe Api::Dashboard::Parking::DetailedViolationSerializer do

    let(:expected_result) do

      {
        id: parking_violation.id,
        parking_ticket_id: ticket.id,
        status: kind_of(String),
        created_at: kind_of(Integer),
        violation_type: kind_of(String),
        parking_lot: {
          id: kind_of(Integer),
          name: kind_of(String)
        },
        agency: {
          id: kind_of(Integer),
          name: kind_of(String)
        },
        officer: {
          id: kind_of(Integer),
          name: kind_of(String),
          email: kind_of(String)
        },
        citation_ticket_id: anything,
        plate_number: kind_of(String),
        images: kind_of(Array),
        history_logs: kind_of(Array),
        comments: kind_of(Array)
      }.deep_stringify_keys
    end

    it 'should returns correct result' do
      expect(subject).to match(expected_result)
    end

  end

end

