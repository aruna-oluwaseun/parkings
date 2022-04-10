require 'rails_helper'

describe Admins::Create do
  subject { described_class.run(payload) }

  let(:admin) { create(:admin, :superadmin) }
  let(:parking_lot_ids) { [] }
  let(:payload) do
    {
      name: Faker::Name.name,
      email: Faker::Internet.email,
      status: 'active',
      username: 'anotheradmin',
      phone: '+48 888 888 888',
      current_user: admin,
      role_type: role_type,
      parking_lot_ids: parking_lot_ids,
      agency_id: agency_id
    }
  end
  let(:parking_lot_id) {}
  let(:agency_id) {}
  let(:new_user) { subject.user }

  describe 'creating town_manager' do
    let(:role_type) { 'town_manager' }

    context 'with parking lot' do
      let(:parking_lots) { create_list(:parking_lot, 3) }
      let(:parking_lot_ids) { parking_lots.pluck(:id).map(&:to_s) }

      it 'assigns user to parking lot' do
        parking_lots.each do |parking_lot|
          expect(parking_lot.reload.town_managers).to include(new_user)
        end
      end
    end
  end

  describe 'creating agency_manager' do
    let(:role_type) { 'agency_manager' }
    let(:agency) { create(:agency) }
    let(:agency_id) { agency.id.to_s }

    it 'assigns user to agency' do
      expect(agency.reload.managers).to include(new_user)
    end

    context 'agency is not defined' do
      let(:agency_id) { nil }

      it 'return errors' do
        expect(subject.errors.full_messages).to include('Agency must be defined when creating agency manager')
        expect(agency.reload.managers).not_to include(new_user)
      end
    end
  end

  describe 'creating agency_officer' do
    let(:role_type) { 'agency_officer' }
    let(:agency) { create(:agency) }
    let(:agency_id) { agency.id.to_s }

    it 'assigns user to agency' do
      expect(agency.reload.officers).to include(subject.user)
    end
  end

  describe 'creating parking_lot_manager' do
    let(:role_type) { 'parking_lot_manager' }
    let(:parking_lots) { create_list(:parking_lot, 3) }
    let(:parking_lot_ids) { parking_lots.pluck(:id).map(&:to_s) }

    it 'assigns user to parking lot' do
      parking_lots.each do |parking_lot|
        expect(parking_lot.reload.parking_admins).to include(subject.user)
      end
    end
  end
end
