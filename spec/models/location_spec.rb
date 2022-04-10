require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'creating location' do
    let(:parking_lot) { create(:parking_lot) }
    let(:location) { parking_lot.location }

    context 'with valid attributes' do
      it 'has to be valid' do
        expect(location).to be_valid
        expect(location.lng).to be_present
        expect(location.ltd).to be_present
        expect(location.city).to be_present
        expect(location.state).to be_present
        expect(location.street).to be_present
        expect(location.country).to be_present
        expect(location.building).to be_present
        expect(location.zip).to be_present
        expect(location.full_address).to be_present
      end
    end

    context 'without zipcode' do
      it 'has to be valid' do
        location.update_attribute(:zip, nil)
        expect(location.zip).to be_nil
        expect(location).to be_valid
        expect(location.full_address).to be_present
      end
    end

    context 'without building' do
      it 'has to be valid' do
        location.update_attribute(:building, nil)
        expect(location.building).to be_nil
        expect(location).to be_valid
        expect(location.full_address).to be_present
      end
    end
  end
end