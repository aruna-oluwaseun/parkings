FactoryBot.define do
  factory :role do
    name { Role::NAMES.sample }
    sequence(:display_name) { |n| I18n.t('role')[name] || "#{Faker::Company.profession}_#{n}" }
  end
end
