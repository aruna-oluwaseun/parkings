require 'rails_helper'

RSpec.describe AgencyType, type: :model do
  describe 'associations' do
    it { should have_one(:agency).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:name)
                  .case_insensitive
                  .with_message(/A law enforcement agency type name with the same name already exists/) }
  end
end
