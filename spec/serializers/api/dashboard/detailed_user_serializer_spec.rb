require 'rails_helper'

describe Api::Dashboard::DetailedUserSerializer do
  subject { described_class.new(admin, { scope: admin }).serializable_hash }

  describe 'associated_parking_lots' do
    let(:parking_lot) { create(:parking_lot, :with_agency) }
    let(:admin) { parking_lot.agency.managers.last }

    it 'returns associated parking lots' do
      expect(subject.dig(:associated_parking_lots)).to eq([{
        id: parking_lot.id, name: parking_lot.name
      }])
    end
  end
end
