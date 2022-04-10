require 'rails_helper'

describe DropdownFields::Dashboard::AgencyList do
  subject { described_class.new(current_user: admin).search }

  let(:admin) { create(:admin, :superadmin) }
  let(:count) { 3 }
  let!(:agencies) { create_list(:agency, count) }

  it 'returns list of agencies' do
    expect(subject.size).to eq count
  end
end
