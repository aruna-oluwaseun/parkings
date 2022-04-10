require 'rails_helper'

RSpec.describe Api::Dashboard::RoleSerializer, type: :serializer do
  describe 'Validating serializer' do
    let(:role) { Role.find_or_create_by(name: :super_admin) }

    before do
      @serializer = Api::Dashboard::RoleSerializer.new(role)
      @serialization = ActiveModelSerializers::Adapter.create(@serializer)
    end

    subject do
      JSON.parse(@serialization.to_json)
    end

    it 'have the same id' do
      expect(subject['id']).to eq(role.id)
    end

    it 'have the same name' do
      expect(subject['name']).to eq(role.display_name)
    end

    it 'have the same permissions' do
      expect(subject['permissions'].first['name']).to eq(role.permissions.first&.name)
      expect(subject['permissions'].first['record_create']).to eq(role.permissions.first&.record_create)
      expect(subject['permissions'].first['record_read']).to eq(role.permissions.first&.record_read)
      expect(subject['permissions'].first['record_update']).to eq(role.permissions.first&.record_update)
      expect(subject['permissions'].first['record_delete']).to eq(role.permissions.first&.record_delete)
    end

    it 'have the same created at date' do
      expect(subject['created_at']).to eq(role.created_at.to_i)
    end

    describe 'predefined role names' do
      context 'Law Enforcement Agency Manager' do
        let(:role) { Role.find_or_create_by(name: :manager) }

        it 'returns verbose name' do
          expect(subject['name']).to eq('Law Enforcement Agency Manager')
        end
      end

      context 'Law Enforcement Agency Officer' do
        let(:role) { Role.find_or_create_by(name: :officer) }

        it 'returns verbose name' do
          expect(subject['name']).to eq('Law Enforcement Agency Officer')
        end
      end

      context 'Parking Operator' do
        let(:role) { Role.find_or_create_by(name: :parking_admin) }

        it 'returns verbose name' do
          expect(subject['name']).to eq('Parking Operator')
        end
      end

      context 'Town Manager' do
        let(:role) { Role.find_or_create_by(name: :town_manager) }

        it 'returns verbose name' do
          expect(subject['name']).to eq('Town Manager')
        end
      end

      context 'Super Admin' do
        let(:role) { Role.find_or_create_by(name: :super_admin) }

        it 'returns verbose name' do
          expect(subject['name']).to eq('Super User')
        end
      end
    end
  end
end
