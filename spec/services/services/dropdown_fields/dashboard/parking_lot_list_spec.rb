require 'rails_helper'

describe DropdownFields::Dashboard::ParkingLotList do
  subject do
    described_class.new({ current_user: admin }).search
  end

  let(:admin) {  create(:admin, role: role) }
  let!(:parking_lots) { create_list(:parking_lot, 2) }

  describe 'admin' do
    let(:role) do
      Role.find_by(name: :super_admin) || create(:role, :super_admin)
    end

    it 'returns list of parking_lots' do
      expect(subject.any?).to be_truthy
      expect(subject.last.keys).to eq %i[value label]
    end
  end

  describe 'town_manager' do
    let(:role) do
      Role.find_by(name: :town_manager) || create(:role, :town_manager)
    end

    context 'with no rights' do
      it 'returns empty list' do
        expect(subject.any?).to be_falsey
      end
    end

    context 'with rights' do
      before do
        parking_lots.each do |lot|
          create(:admin_right, subject: lot, admin: admin)
        end
      end

      it 'returns list of parking_lots' do
        expect(subject.any?).to be_truthy
      end
    end
  end
end
