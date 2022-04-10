require 'rails_helper'

destroy_models = [
  Agency,
  ParkingSlot,
  ParkingLot,
  ParkingSession,
  Vehicle,
  Camera,
  Admin,
  Role
]

describe Build::DatabaseBuilder do
  before(:all) do
    create(:user, :confirmed)
  end

  subject { Build::DatabaseBuilder.run }

  describe 'building database' do

    after { subject }

    context 'created records deletion' do
      it "destroys existing #{destroy_models.map(&:name).join(', ')}" do
        destroy_models.each do |entity|
          expect(entity).to receive(:destroy_all).and_call_original
        end
      end
    end

    context 'filling database with new records' do
      it 'creates models' do
        Role.destroy_all
        expect { subject }.to change(Agency, :count)
        .and change(Role, :count)
        .and change(Admin, :count)
        .and change(ParkingLot, :count)
        .and change(ParkingSlot.occupied, :count)
        .and change(Location, :count)
        .and change(Parking::Rule, :count)
        .and change(ParkingSlot, :count)
        .and change(Parking::Setting, :count)
        .and change(Camera, :count)
        .and change(Kiosk, :count)
        .and change(Ksk::Token, :count)
        .and change(Vehicle, :count)
        .and change(ParkingSession, :count)
        .and change(Alert, :count)
      end
    end
  end
end
