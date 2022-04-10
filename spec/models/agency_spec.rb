require 'rails_helper'

RSpec.describe Agency, type: :model do
  describe 'creating agency' do
    context 'with valid factory' do
      let!(:agency) { create(:agency, :with_avatar) }

      it 'should be valid' do
        expect(agency.valid?).to eq(true)
      end

      context 'avatar' do
        it 'should has avatar' do
          expect(agency.avatar).to be_present
        end
        
        it 'should has thumbnail' do
          expect(agency.avatar_thumbnail).to be_present
        end

        it 'has thumbnail dimensions 200x200' do
          dimensions = agency.avatar_thumbnail.image.variation.transformations[:resize]
          expect(dimensions).to eq('200x200')
        end
      end

    end

    it { is_expected.to validate_size_of(:avatar).less_than(10.megabytes) }

    describe 'validations' do
      it { should validate_uniqueness_of(:name)
                    .case_insensitive
                    .with_message(/A law enforcement agency name with the same name already exists/) }
    end
  end
end
