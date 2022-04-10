require 'rails_helper'

describe Admins::Update do
  subject { described_class.run(payload) }

  let(:superadmin) { create(:admin, :superadmin) }
  let(:parking_lot_ids) { [] }
  let(:agency_id) { nil }
  let(:role_type) { role_type }
  let(:payload) do
    {
      user: admin,
      email: admin.email,
      status: admin.status,
      username: admin.username,
      name: admin.name,
      role_type: role_type,
      parking_lot_ids: parking_lot_ids,
      agency_id: agency_id,
      current_user: superadmin
    }
  end

  describe 'updating from town manager to be as agency manager' do
    let(:role_type) { 'agency_manager' }
    let(:parking_lot) { create(:parking_lot) }
    let(:admin) { parking_lot.town_managers.last }
    let(:agency) { create(:agency) }
    let(:agency_id) { agency.id.to_s }

    it { is_expected.to be_valid }

    it 'updates admin users role' do
      subject
      expect(admin.reload.agency_manager?).to be_truthy
    end
  end

  describe 'updating users data' do
    let(:admin) { create(:admin) }
    let(:payload) do
      {
        user: admin,
        email: admin.email,
        status: admin.status,
        username: 'updatedusername',
        name: 'nobodybutyou',
        current_user: superadmin,
        role_type: 'parking_lot_manager'
      }
    end

    it { is_expected.to be_valid }

    it 'updates name and username' do
      subject
      expect(admin.reload.username).to eq 'updatedusername'
      expect(admin.reload.name).to eq 'nobodybutyou'
    end
  end

  describe 'updating town_manager' do
    let(:role_type) { 'town_manager' }
    let(:parking_lot) { create(:parking_lot) }
    let(:new_parking_lot) { create(:parking_lot) }
    let(:admin) { parking_lot.town_managers.last }
    let(:parking_lot_ids) { [new_parking_lot.id] }

    it { is_expected.to be_valid }

    it 're assigns to a new parking lots' do
      subject
      expect(parking_lot.reload.town_managers).not_to include(admin)
      expect(new_parking_lot.reload.town_managers).to include(admin)
    end
  end

  describe 'updating agency_manager' do
    let(:role_type) { 'agency_manager' }
    let(:agency) { create(:agency, :with_manager) }
    let(:new_agency) { create(:agency) }
    let(:admin) { agency.managers.last }
    let(:agency_id) { new_agency.id.to_s }

    it { is_expected.to be_valid }

    it 're assigns to a new agency' do
      subject
      expect(agency.reload.managers).not_to include(admin)
      expect(new_agency.reload.managers).to include(admin)
    end
  end

  describe 'updating agency_officer' do
    let(:role_type) { 'agency_officer' }
    let(:agency) { create(:agency, :with_officer) }
    let(:new_agency) { create(:agency) }
    let(:admin) { agency.officers.last }
    let(:agency_id) { new_agency.id.to_s }

    it { is_expected.to be_valid }

    it 're assigns to a new agency' do
      subject
      expect(agency.reload.officers).not_to include(admin)
      expect(new_agency.reload.officers).to include(admin)
    end
  end

  describe 'updating parking_lot_manager' do
    let(:role_type) { 'parking_lot_manager' }
    let(:parking_lot) { create(:parking_lot, :with_admin) }
    let(:admin) { parking_lot.parking_admins.last }
    let(:new_parking_lot) { create(:parking_lot) }
    let(:parking_lot_ids) { [new_parking_lot.id] }

    it { is_expected.to be_valid }

    it 're assigns to a new parking lots' do
      subject
      expect(parking_lot.reload.parking_admins).not_to include(admin)
      expect(new_parking_lot.reload.parking_admins).to include(admin)
    end
  end
end
