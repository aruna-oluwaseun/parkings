FactoryBot.define do
  factory :agency do
    name { Faker::Company.name }
    email { Faker::Internet.email }
    phone { Faker::Phone.number }
    agency_type

    after :create do |agency|
      create :location, subject: agency
    end

    trait :with_officer do
      after :create do |agency|
        agency.officers << create(:admin, :officer)
      end
    end

    trait :with_manager do
      after :create do |agency|
        agency.managers << create(:admin, :manager)
      end
    end

    trait :with_avatar do
      after :create do |agency|
        filename = 'test.jpg'
        content_type = 'image/jpg'
        file = Rack::Test::UploadedFile.new("spec/files/#{filename}", content_type)
        agency.avatar = { io: file, filename: filename }
      end
    end
  end
end
