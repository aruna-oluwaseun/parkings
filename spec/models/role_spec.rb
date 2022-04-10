require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'creating role' do
    it 'has valid factory', empty_roles_table: true do
      role = create(:role)
      expect(role).to be_valid
    end
  end
end
