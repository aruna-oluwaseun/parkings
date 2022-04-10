require 'rails_helper'

describe RolesUpdateCommand do
  subject { described_class.new }

  before { subject.execute }

  describe 'Roles with full access to entities' do
    described_class::CRUD_OPS.each do |role_name, entities|
      context "#{role_name}" do
        let(:role) { Role.find_by_name(role_name) }

        entities.each do |entity|
          let(:permission) { role.permissions.find_by_name(entity) }

          it 'permits all from entity' do
            expect(permission.record_create).to be_truthy
            expect(permission.record_update).to be_truthy
            expect(permission.record_read).to be_truthy
            expect(permission.record_delete).to be_truthy
          end
        end
      end
    end

    describe 'super_admin' do
      it 'has full access' do
        expect(Role.where(name: :super_admin).all? { |role| role.full }).to be_truthy
      end
    end
  end

  describe 'Roles with readonly access to entities' do
    described_class::READ_OPS.each do |role_name, entities|
      context "#{role_name}" do
        let(:role) { Role.find_by_name(role_name) }

        entities.each do |entity|
          let(:permission) { role.permissions.find_by_name(entity) }

          it 'permits all from entity' do
            expect(permission.record_create).to be_falsey
            expect(permission.record_update).to be_falsey
            expect(permission.record_read).to be_truthy
            expect(permission.record_delete).to be_falsey
          end
        end
      end
    end
  end
end
