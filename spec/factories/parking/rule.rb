FactoryBot.define do
  factory :parking_rule, class: 'Parking::Rule' do
    name { Parking::Rule.names.keys.sample }
    association :lot, factory: :parking_lot
    officer do
      if lot.agency
        lot.agency.officers << create(:admin, :officer)
        lot.agency.officers.last
      end
    end

    trait :with_recipients do
      after :create do |rule|
        create :parking_recipient, rule: rule
      end
    end
  end
end
