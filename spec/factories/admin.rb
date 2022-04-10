FactoryBot.define do
  factory :admin do
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    username { Faker::Admin.username }
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    phone { Faker::Phone.number }
    role { Role.find_by(name: :manager) || create(:role, :manager) }

    trait :superadmin do
      role { Role.find_by(name: :super_admin) || create(:role, :super_admin) }
    end

    trait :parking_admin do
      role { Role.find_by(name: :parking_admin) || create(:role, :parking_admin) }
    end

    trait :officer do
      role { Role.find_by(name: :officer) || create(:role, :officer) }
    end

    trait :manager do
      role { Role.find_by(name: :manager) || create(:role, :manager) }
    end

    trait :town_manager do
      role { Role.find_by(name: :town_manager) || create(:role, :town_manager) }
    end

    trait :parking_admin do
      role { Role.find_by(name: :parking_admin) || create(:role, :parking_admin) }
    end
  end
end
