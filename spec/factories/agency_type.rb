FactoryBot.define do
  factory :agency_type do
    name { Faker::Company.unique.name }

    trait :with_default_name do
      name { AgencyType::DEFAULT_NAMES.sample }
    end
  end
end
