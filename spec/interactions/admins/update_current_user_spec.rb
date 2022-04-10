require 'rails_helper'

describe Admins::UpdateCurrentUser do
  subject { described_class.run(payload) }

  let(:admin) { create(:admin, password: 'ABC12abc') }
  let(:update_attributes) do
    {
      agency_id: nil,
      email: admin.email,
      id: admin.id,
      name: admin.name,
      parking_lot_ids: [],
      parking_lots: [],
      phone: admin.phone,
      username: admin.username,
      current_user: admin
    }
  end

  describe 'avatar' do
    context 'deletion' do
      let(:admin) { create(:admin, :with_avatar) }
      let(:payload) do
        {
          **update_attributes,
          delete_avatar: true
        }
      end

      it 'has avatar' do
        expect(admin.avatar.attachment).to be_present
      end

      it 'purge avatar' do
        subject
        expect(admin.reload.avatar.attachment).to be_nil
      end
    end
  end

  describe 'change password' do
    let(:payload) do
      {
        **update_attributes,
        old_password: 'ABC12abc',
        password: 'ABC10abc'
      }
    end

    it { is_expected.to be_valid }

    context 'old_password' do
      let(:payload) do
        {
          **update_attributes,
          old_password: 'wrongpassword',
          password: 'ABC10abc'
        }
      end

      it { is_expected.not_to be_valid }

      it 'returns error on old password field' do
        expect(subject.errors.full_messages).to include('old password Your old password is invalid')
      end
    end
  end
end
