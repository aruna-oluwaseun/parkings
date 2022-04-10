require 'rails_helper'

describe Parking::Rule, type: :model do
  it { is_expected.to have_many :recipients }
  it { is_expected.to have_many :admins }
  it { is_expected.to have_many :violations }

  describe 'validations' do
    subject { parking_lot.rules.last }

    let(:agency) { create(:agency, :with_officer) }
    let(:parking_lot) { create(:parking_lot, :with_rules, agency: agency) }

    before { subject.officer = officer }

    describe '#agency_officer_only' do
      context 'with valid officer' do
        let(:officer) { agency.officers.last }

        it { is_expected.to be_valid }
      end

      context 'with invalid officer' do
        let(:officer) { create(:admin, :officer) }

        it { is_expected.not_to be_valid }
        it 'return error' do
          subject.valid?
          expect(subject.errors.full_messages).to include(
            'officer Is not an agency officer'
          )
        end
      end
    end

    describe 'only one officer can choose one rule' do
      let(:officer) { agency.officers.last }

      context 'officer has not yet assigned to rule' do
        it 'should be valid' do
          expect(subject).to be_valid
          expect(subject.errors).to be_empty
        end
      end

      context 'officer has already assigned to rule' do
        it 'should not valid' do
          subject.save!

          parking_rule = parking_lot.rules.first
          parking_rule.officer = officer

          expect(parking_rule).to be_invalid
          expect(parking_rule.errors.full_messages).to include(
            'officer Officer has already been assigned to another rule'
          )
        end
      end

      context 'remove officer from a rule' do
        it 'should be success' do
          subject.save!
          subject.officer = nil

          expect(subject).to be_valid
          expect(subject.errors).to be_empty
        end
      end
    end

  end

  describe Parking::Rule, 'name' do
    let(:agency) { create(:agency, :with_officer) }
    let(:parking_lot) { create(:parking_lot, :with_rules, agency: agency) }

    let(:parking_rule_names) do
      {
        overlapping: 0,
        blocking_space: 1,
        exceeding_grace_period: 2,
        unpaid: 3
      }
    end

    subject { described_class.new(lot_id: parking_lot.id) }

    it 'has valid a name' do
      parking_rule_names.each do |type, value|
        subject.name = value
        subject.save
        expect(subject.name).to eql(type.to_s)
      end
    end

    it 'raises invalid historical name' do
      expect { build(:parking_rule, name: :leaving_halfway) }
      .to raise_error(ArgumentError)
      .with_message(/is not a valid name/)
    end
  end

  describe Parking::Rule, 'name' do
    let(:parking_rule_names) do
      {
        overlapping: 0,
        blocking_space: 1,
        exceeding_grace_period: 2,
        unpaid: 3
      }
    end
    subject { described_class.new }

    it 'has valid a name' do
      parking_rule_names.each do |type, value|
        subject.name = value
        subject.save
        expect(subject.name).to eql(type.to_s)
      end
    end

    it 'raises invalid historical name' do
      expect { build(:parking_rule, name: :leaving_halfway) }
      .to raise_error(ArgumentError)
      .with_message(/is not a valid name/)
    end
  end
end
