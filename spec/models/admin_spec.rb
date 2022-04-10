require 'rails_helper'

describe Admin, type: :model do
  # describe 'creating admin' do
  #   it 'has valid factory' do
  #     admin = create(:admin)
  #     expect(admin.valid?).to eq(true)
  #   end
  # end

  # describe 'Citext email and username' do
  #   let(:username) { 'psadmin' }
  #   let(:email)    { 'psadmin@example.com' }
  #   let!(:admin)    { create(:admin, username: username, email: email) }

  #   subject { described_class.where(email: 'PSAdMiN@example.com', username: 'PSAdMiN') }

  #   it  { is_expected.not_to be_empty }
  # end

  describe '#managed_users' do
    describe 'managed_by_town_manager' do
      subject { town_manager.managed_users }

      let(:town_manager) { parking_lot.town_managers.last }
      let(:parking_lot) { create(:parking_lot, :with_agency, :with_admin) }

      it 'returns 2 managed users' do
        expect(subject.size).to eq 2
      end

      it "includes parking lots agency's officer" do
        expect(town_manager.managed_users).to include(parking_lot.agency.officers.last)
      end

      it "includes parking lots parking admins" do
        expect(town_manager.managed_users).to include(parking_lot.parking_admins.last)
      end
    end

    # Note: change this to parking operator once
    # role management work is implemented
    describe 'managed_by_parking_admin' do
      subject { parking_admin.managed_users }

      let(:parking_lot) { create(:parking_lot, :with_agency, :with_admin) }
      let(:parking_admin) { parking_lot.parking_admins.last }

      it 'returns 2 managed users' do
        expect(subject.size).to eq 1
      end

      it "includes parking lots agency's officer" do
        expect(parking_admin.managed_users).to include(parking_lot.agency.officers.last)
      end
    end

    describe 'managed_by_agency_manager' do
      subject { manager.managed_users }

      let(:agency) { create(:agency, :with_manager, :with_officer) }
      let(:manager) { agency.managers.last }

      it 'returns 1 managed user' do
        expect(subject.size).to eq 1
      end

      it 'includes agency officer' do
        expect(subject).to include(agency.officers.last)
      end
    end
  end

  describe '#agency_manager?' do
    subject { admin.agency_manager? }

    let(:agency) { create(:agency, :with_manager) }
    let(:admin) { agency.managers.last }

    it { is_expected.to be_truthy }
  end

  describe '#agency_manager?' do
    subject { admin.agency_manager? }

    let(:agency) { create(:agency, :with_manager) }
    let(:admin) { agency.managers.last }

    it { is_expected.to be_truthy }
  end

  describe '#agency_officer?' do
    subject { admin.agency_officer? }

    let(:agency) { create(:agency, :with_officer) }
    let(:admin) { agency.officers.last }

    it { is_expected.to be_truthy }
  end
end
