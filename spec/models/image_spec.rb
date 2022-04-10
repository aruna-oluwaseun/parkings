require 'rails_helper'

RSpec.describe Image, type: :model do
  describe 'creating Image' do
    it 'has valid factory' do
      image = create(:image)
      expect(image).to be_valid
      expect(image.file).to be_present
    end
  end
end
