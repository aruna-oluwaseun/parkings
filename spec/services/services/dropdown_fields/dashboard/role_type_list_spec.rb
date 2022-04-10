require 'rails_helper'

describe DropdownFields::Dashboard::RoleType do
  subject { described_class.new({ current_user: admin }).search }

  describe 'super admin user' do
    let(:admin) { create(:admin, :superadmin) }
    let(:expected_list) do
      [
        { value: "super_admin", label: "Super User" },
        { value: "town_manager", label: "Town Manager" },
        { value: "parking_lot_manager", label: "Parking Operator" },
        { value: "agency_manager", label: "Law Enforcement Agency Manager" },
        { value: "agency_officer", label: "Law Enforcement Officer" }
      ]
    end

    it 'returns role types' do
      expect(subject).to match_array expected_list
    end
  end
end
