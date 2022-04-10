require 'rails_helper'

RSpec.describe Role::Permission, type: :model do

  describe 'creating roles permission', empty_roles_table: true do
    it 'has valid factory' do
      permission = build(:role_permission)
      expect(permission.valid?).to eq(true)
    end
  end

  describe '#permission_available' do
    let(:expected_list) do
      [
        { label: 'Roles', name: 'Role' },
        { label: 'Users', name: 'Admin' },
        { label: 'Subscribers', name: 'User' },
        { label: 'Vehicles', name: 'Vehicle' },
        { label: 'Parking Lots', name: "ParkingLot" },
        { label: 'Law Enforcement Agencies', name: "Agency" },
        { label: 'Law Enforcement Agency Types', name: "AgencyType" },
        { label: 'Payments', name: 'Payment' },
        { label: 'Disputes', name: 'Dispute' },
        { label: 'Violations', name: 'Parking::Violation' },
        { label: 'Messages', name: 'Message' },
        { label: 'Streaming', name: 'Camera' },
        { label: 'System Reports', name: 'Report' },
        { label: 'Notification Configurations', name: 'User::Notification' },
        { label: 'Citation Ticket', name: 'Parking::CitationTicket' },
      ]
    end
    subject { described_class.permission_available }
    it 'should return all permissions listed in PERMISSIONS_AVAILABLE' do
      expect(subject).to match_array(expected_list)
    end
  end
end
