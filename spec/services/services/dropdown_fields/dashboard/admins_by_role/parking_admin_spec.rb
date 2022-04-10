require 'rails_helper'

describe DropdownFields::Dashboard::AdminsByRole::ParkingAdmin do
  subject { described_class.new(current_user: admin).search }

  let!(:admin) { create(:admin, :parking_admin) }

  it { is_expected.to be_present }

  it 'returns list of admins' do
    expect(subject).to eq [{ value: admin.id, label: admin.username }]
  end
end
