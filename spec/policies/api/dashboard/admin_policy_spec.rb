require 'rails_helper'

describe Api::Dashboard::AdminPolicy do
  subject { policy.apply(:update?) }

  let(:policy) { described_class.new(admin, user: user) }

  describe '#update?' do
    let(:user) { create(:admin) }
    let(:admin) { user }

    it { is_expected.to be_truthy }

    context 'forbidden' do
      let(:admin) { create(:admin) }

      it { is_expected.to be_falsey }
    end
  end
end
