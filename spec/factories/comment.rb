FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.sentence }
    admin

    trait :with_violation do
      subject { parking_violation || create(:parking_violation) }
    end
  end
end
