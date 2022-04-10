FactoryBot.define do
  factory :parking_ticket, class: 'Parking::Ticket' do
    association :violation, factory: :parking_violation
    admin
    agency

    trait :unassigned do
      admin { nil }
    end
  end
end
